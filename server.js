var express = require('express'),
    app = express(),
    session = require('express-session'),
    server = require('http').createServer(app),
    io = require('socket.io').listen(server),
    mongoose = require('mongoose'),
    swig = require('swig'),
    Message = require('./model/message'),
    Thread = require('./model/thread');

var AssistantV1 = require('watson-developer-cloud/assistant/v1');
var ToneAnalyzerV3 = require('watson-developer-cloud/tone-analyzer/v3');

var watsonAssistant = new AssistantV1({
    version: '2018-02-16',
    username: '8ff3b92f-2f3f-4f42-8899-6740db80f85b',
    password: 'vP0Nol6Lijw2',
    url: 'https://gateway.watsonplatform.net/assistant/api'
});

var toneAnalyzer = new ToneAnalyzerV3({
    version: '2017-09-21',
    url: "https://gateway.watsonplatform.net/tone-analyzer/api",
    username: "d148c074-86bd-41cd-91ad-e19e18095792",
    password: "xdmNVR0mS3JA"
});


const WORKSPACE_ID = '9c30407b-faea-4734-a169-e411efacde7a';

app.use(session({
    secret: 'q1w2e3',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: true }
}));

app.engine('swig', swig.renderFile);
//app.set('view engine', 'pug');
app.set('view engine', 'swig');

var sess;

//mongoose.connect('mongodb://127.0.0.1:27017/chat');
mongoose.connect('mongodb://user0:password0@ds245512.mlab.com:45512/chitchat');

var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function () {
    console.log('MongoDB Connected..');
});

server.listen(process.env.PORT || 3000);

var usernames = [];
var threadCode = '';

io.sockets.on('connection', function (socket) {
    console.log('Socket Connected.');

    socket.on('send message', function (data) {
        data.author = socket.username;
        data.threadCode = sess.threadCode || generateThreadCode();
        //console.log(data);
        sess.messages.push(data);
        //console.log(sess);
        io.sockets.emit('new message', { author: socket.username, message: data.message, date: data.date });
    });

    socket.on('send message persist', function (data) {

        var newMessage = new Message({
            author: socket.username,
            message: data.message,
            code: sess.threadCode
        });
        newMessage.save(function (err, newMessage) {
            //console.log(newMessage);
            if (err) return console.error(err);
            // Thread.findOneAndUpdate({"code": sess.threadCode}, { $push: { messages: newMessage } }, { new: true }, function(err, newThread) {
            //     console.log(newThread);
            //     if (err) {
            //         return res.status(404).json(err);
            //     }
            //     io.sockets.emit('new message', {author: newMessage.author, message: newMessage.message, date: newMessage.date});
            // });

            Thread.findOneAndUpdate({ "code": sess.threadCode }, { $push: { messages: newMessage, trends: Date.now() } }, { new: true }).then((newThread) => {
                console.log(sess);
                console.log(newThread);


                //     var toneParams = {
                //     'tone_input': { 'text': newMessage.message },
                //     'content_type': 'application/json', 
                //     'sentences': false
                //   };

                //   toneAnalyzer.tone(toneParams, function (error, analysis) {
                //     if (error) {
                //       console.log(error);
                //     } else { 
                //     getToneIcon(analysis.document_tone.tones[0].tone_id);
                //       console.log(JSON.stringify(analysis, null, 2));
                //       io.sockets.emit('tone update', {author: newMessage.author, message: newMessage.message, date: newMessage.date});
                //     }
                //   });

                utterances = [
                    {
                        text: newMessage.message
                    }
                ];

                var toneChatParams = {
                    utterances: utterances
                };

                toneAnalyzer.toneChat(toneChatParams, function (error, analysis) {
                    if (error) {
                        console.log(error);
                    } else {
                        console.log(JSON.stringify(analysis, null, 2));
                        io.sockets.emit('new message', {
                            author: newMessage.author,
                            message: newMessage.message,
                            date: newMessage.date,
                            tones: getFormattedTones(analysis.utterances_tone[0].tones)
                        });
                    }
                }); 0;





                if (sess.ai) {
                    setTimeout(function () {
                        watsonAssistant.message({
                            workspace_id: WORKSPACE_ID,
                            input: { 'text': newMessage.message },
                            headers: {
                                'Custom-Header': 'custom',
                                'Accept-Language': 'custom'
                            }
                        }, function (err, result, response) {
                            if (err)
                                console.log('error:', err);
                            else {
                                console.log(JSON.stringify(result, null, 2));
                                var newBotMessage = new Message({
                                    author: "Bot",
                                    message: result.output.text[0],
                                    code: sess.threadCode
                                });

                                newBotMessage.save(function (err, newBotMessage) {
                                    Thread.findOneAndUpdate(
                                        { "code": sess.threadCode },
                                        { $push: { messages: newBotMessage, trends: Date.now() } },
                                        { new: true }).then((newThread) => {

                                            io.sockets.emit('new message', { author: "Bot", message: newBotMessage.message, date: newBotMessage.date });

                                        }).catch((error) => {
                                            return res.status(404).json(error);
                                        });
                                });
                            }

                        });
                    }, 2000);
                }

            }).catch((error) => {
                return res.status(404).json(error);
            });

        });

    });

    socket.on('new user', function (data, callback) {

        if (usernames.indexOf(data) != -1) {
            callback(false);
        } else {
            callback(true);
            socket.username = data;
            usernames.push(socket.username);
            updateUsernames();
        }
        //console.log(usernames);
    });

    socket.on('disconnect', function (data) {
        if (!socket.username) {
            updateUsernames();
        }
        usernames.splice(usernames.indexOf(socket.username), 1);
        updateUsernames();
    });

    socket.on('typing', function (data, callback) {

        console.log(data.username + " is typing...");
        io.sockets.emit('typing', { user: data.username });
    });

    socket.on('not typing', function (data, callback) {

        console.log(data.username + " stopped typing...");
        io.sockets.emit('not typing', { user: data.username });
    });

    socket.on('ai on', function (data, callback) {
        sess.ai = true;
    });

    socket.on('ai off', function (data, callback) {
        sess.ai = false;
    });

    function updateUsernames() {
        io.sockets.emit('usernames', usernames);
    }
});


app.get('/watson', function (req, res) {

    // watsonAssistant.message({
    //     workspace_id: WORKSPACE_ID,
    //     input: {'text': 'what is my order status?'},
    //     headers: {
    //       'Custom-Header': 'custom',
    //       'Accept-Language': 'custom'
    //     }
    //   },  function(err, result, response) {
    //     if (err)
    //       console.log('error:', err);
    //     else
    //       console.log(JSON.stringify(result, null, 2));
    //   });

    //   var text = 'Team, I know that times are tough! Product sales have been disappointing for the past three quarters. We have a competitive product, but we need to do a better job of selling it!'

    //   var toneParams = {
    //     'tone_input': { 'text': text },
    //     'content_type': 'application/json'
    //   };

    //   toneAnalyzer.tone(toneParams, function (error, analysis) {
    //     if (error) {
    //       console.log(error);
    //     } else { 
    //       console.log(JSON.stringify(analysis, null, 2));
    //     }
    //   }); 0;


    utterances = [
        {
            text: "yo, there's a problem with this shit!"
        }
    ];

    var toneChatParams = {
        utterances: utterances
    };

    toneAnalyzer.toneChat(toneChatParams, function (error, analysis) {
        if (error) {
            console.log(error);
        } else {
            console.log(JSON.stringify(analysis, null, 2));
        }
    }); 0;

});


app.get('/', function (req, res) {

    sess = req.session;
    sess.threadCode = sess.threadCode || generateThreadCode();
    sess.messages = [];

    Thread.find({}, function (err, threads) {
        if (err) return console.error(err);
        //res.sendFile(__dirname + '/index.html');
        res.render('index', {
            threads: threads,
            title: 'chitchat'
        });
    });


});

app.get('/new', function (req, res) {

    // Message.remove({})
    //     .then(() => Message.insertMany(sess.messages))
    //     .then((msgs) => {
    //         console.log(msgs);
    //         var newThread = new Thread({ 
    //             messages: msgs, 
    //             code: sess.threadCode
    //         });
    //         newThread.save(function (err, newThread) {
    //             if (err) return console.error(err);
    //             res.status(200).json({code: newThread.code});
    //         });
    //     });

    var newThread = new Thread({
    });
    newThread.save(function (err, newThread) {
        if (err) return console.error(err);
        //res.status(200).json({ code: newThread.code });
        res.redirect('/' + newThread.code);
    });
});

app.get('/:code', function (req, res, next) {
    var codeParam = req.params.code;
    sess = req.session;
    sess.threadCode = codeParam;

    Thread.find({
        'code': codeParam
    }).populate('messages').then((thread) => {
        console.log(thread[0].trending);
        if (thread == null || thread.length == 0) return res.status(404).json(err);
        res.render('thread-view', {
            thread: thread[0],
            threadLink: req.protocol + '://' + req.headers.host + '/' + codeParam,
            title: codeParam
        });
    }).catch((err) => {
        if (err) {
            //console.log(err);
            res.redirect('/');
            //return res.status(404).json(err);
        }
    });
    /*
    Message.find({
        'threadCode': codeParam
    }).then((messages) => {
        console.log(messages);
        res.render('single-thread', {messages: messages});
    }).catch((err) => {
        if (err) {
            return res.status(404).json(err);
        }
    });
    */
});

function generateThreadCode() {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 6; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}

// function getToneIcon(tone) {
//     if(tone == ) {

//     }
// }

function getFormattedTones(toneArr) {
    console.log(toneArr);
    var toneStr = "";
    toneArr.forEach(function (tone, i) {
        toneStr += tone.tone_name + ", ";
    });

    return toneStr.slice(0, -2);
}