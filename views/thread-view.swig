{% extends 'layout.swig' %} 
{% block content %}
  <div class="container">
    <div class="row">
      <div class="col-md-12"> 
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><a href="/">Home</a></li>
          <li class="breadcrumb-item active">{{thread.code}} 
            <a href="#" data-toggle="tooltip" class="copy-button"
            data-clipboard-text="{{threadLink}}">
            <i class="fa fa-link ml-1"></i>
            </a></li>
        </ol>
      </div>
    </div>
    <div id="mainWrapper">
    <div class="row">
      <div class="col-md-9"> 
<div class="jumbotron">
<div id="chatWindowWrapper">
<div id="chatWindow">
{#}
{% for message in thread.messages %}

  {% if loop.length > loop.index %}
    {% if thread.messages[loop.index0]['author'] == thread.messages[loop.index0 + 1]['author'] %}
    <div class="message-wrapper">
    <div class="message-out">
      <div class="alert alert-info">
        <p class="mb-0">{{message.message}}</p>
      </div>
    </div>
    </div>
    {% else %}
    <div class="message-wrapper">
      <div class="message-out">
      <strong class="text-info">{{message.author}}</strong><br>
      <div class="alert alert-info"><p class="mb-0">{{message.message}}</p></div><br>
      <small>{{message.date}}</small></div>
      </div>
    {% endif %}
  {% endif %}
{% endfor %} #}

{% for message in thread.messages %}
{% if message.author == "Bot" %}
<div class="message-wrapper">
      <div class="message-out">
      <strong class="text-danger">{{message.author}}</strong><br>
      <div class="alert alert-danger"><p class="mb-0">{{message.message}}</p></div><br>
      <small>{{message.date}}</small></div>
      </div>
{% else %}
    <div class="message-wrapper">
      <div class="message-out">
      <strong class="text-warning">{{message.author}}</strong><br>
      <div class="alert alert-warning"><p class="mb-0">{{message.message}}</p></div><br>
      <small>{{message.date}}</small></div>
      </div>
{% endif %}
{% endfor %}
</div>
<small class="typing-note"></small>
</div>
                    <form id="messageForm">
                    <div class="form-group mt-2">
                    <div class="input-group">
                    <input type="text" class="form-control form-control-lg" id="message" placeholder="Say something...">
                    <div class="input-group-append">
                      <input type="submit" class="input-group-btn btn btn-primary" value="Send">
                    </div>
                    </div>
                    </div> </form>
</div>
      </div>
      <div class="col-md-3">
      <ul id="users" class="list-group">
  
</ul>

<div class="form-group">
                  <div class="custom-control custom-checkbox mt-2">
                    <input type="checkbox" class="custom-control-input" id="customCheck1">
                    <label class="custom-control-label" for="customCheck1">AI</label>
                  </div>
                </div>

<br>
<b>Tone analysis:</b>
<pre id="toneAnalyzerWindow"></pre>
<br>
<!--<small class="text-muted">* powered by IBM Watson</small>-->
      </div>
    </div>
</div>
    <div id="nameModal" class="modal">
  <div class="modal-dialog" role="document">
  <form id="usernameForm">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Join <span class="text-primary">{{thread.code}}</span></h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>Username:</p>
        <div class="form-group">
             <input type="text" class="form-control form-control-lg" id="username">
        </div>
                        
      </div>
      <div class="modal-footer">
        <input type="submit" class="btn btn-primary" value="Join"> 
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
    </form>
  </div>
</div>

  </div>

{% endblock %}

  {% block javascripts %}
  <script>
$('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});

  $(function() {

    $("#customCheck1").change(function() {
      if($(this).prop('checked') == true) {
           socket.emit('ai on', { 
                    date: Date.now()
                }); 
      } else {
          socket.emit('ai off', { 
                    date: Date.now()
                });
      }
  });

    $('[data-toggle="tooltip"]').tooltip();

    $("#chatWindowWrapper").slimScroll({
        height: '400px',
        start: 'bottom'
    });

    $('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});

    $('#nameModal').modal('show'); 
    username = '';
    var socket = io.connect();
var $chat = $('#chatWindow');
var $messageForm = $('#messageForm');
            var $message = $("#message");
            var $usernameForm = $('#usernameForm');
            var $users = $('#users');
            var $username = $('#username');
            var $error = $('#error');

            $usernameForm.submit(function(e){  
                e.preventDefault();  
                username = $username.val();
                console.log('Submitted');
                socket.emit('new user', username, function(data){  
                    if(data){    
                        $('#nameModal').modal('hide');    
                        $('#mainWrapper').show();  
                        $('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});
                    } else{  
                        $error.html('Username is taken');
                    }
                });
            });

$messageForm.submit(function (e) {
                e.preventDefault();
                console.log('Submitted');
                socket.emit('send message persist', { 
                    message: $message.val(), 
                    date: Date.now()
                });  
                $message.val('');
            });

    socket.on('new message', function(data) {  
      console.log(data);
      if(data.author == username) {
        $chat.append('<div class="message-in"><strong class="text-info">'+data.author+'</strong><br><div class="alert alert-info"><p class="mb-0">'+data.message+'</p></div><br><small>'+data.date+'</small></div>');
      } else if(data.author == "Bot"){
        $chat.append('<div class="message-out"><strong class="text-danger">'+data.author+'</strong><br><div class="alert alert-danger"><p class="mb-0">'+data.message+'</p></div><br><small>'+data.date+'</small></div>');
      } else {
        $chat.append('<div class="message-out"><strong class="text-warning">'+data.author+'</strong><br><div class="alert alert-warning"><p class="mb-0">'+data.message+'</p></div><br><small>'+data.date+'</small></div>');
      }
                $('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});
if(data.tones.length > 0) {
$("#toneAnalyzerWindow").append(data.author + ' is <span class="tone">' + data.tones + '</span><br>');
}
                
            });

            socket.on('usernames', function(data){  
                var html = '';
                for(i = 0; i < data.length; i++){   
                    html += '<li class="list-group-item d-flex justify-content-between align-items-center' + ((data[i] == username) ? ' active': '') + '" data-username="'+ data[i] +'">' + data[i] + '<i class="status-icon fa fa-pencil"></i></li>';  
                }  
                $users.html(html);
            });

            var typing = false;
var timeout = undefined;

function timeoutFunction(){
  typing = false;
  socket.emit('not typing', { 
                    username: username
                });
}

function onKeyDownNotEnter() {
  if(typing == false) {
    typing = true
    socket.emit('typing', { 
                    username: username
                });
    timeout = setTimeout(timeoutFunction, 3000);
  } else {
    clearTimeout(timeout);
    timeout = setTimeout(timeoutFunction, 3000);
  }

}

$("#message").keydown(function(){
  onKeyDownNotEnter();
});

socket.on('typing', function(data) { 
  if(data.user != username) {
    $("[data-username='"+data.user+"'] .status-icon").show();
    $(".typing-note").text(data.user + " is typing...").show();
    $('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});
  }
});

socket.on('not typing', function(data) { 
  if(data.user != username) {
    $("[data-username='"+data.user+"'] .status-icon").hide();
    $(".typing-note").hide();
    $('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});
  }
});

var clipboard = new Clipboard('.copy-button');

$('.copy-button').tooltip({
  trigger: 'click',
  placement: 'top'
});

function setTooltip(message) {
  $('.copy-button').tooltip('hide')
    .attr('data-original-title', message)
    .tooltip('show');
}

function hideTooltip() {
  setTimeout(function() {
    $('.copy-button').tooltip('hide');
  }, 1000);
}


clipboard.on('success', function(e) {
  setTooltip('Copied!');
  hideTooltip();
});

clipboard.on('error', function(e) {
  setTooltip('Failed!');
  hideTooltip();
});

$('#chatWindowWrapper').slimScroll({scrollTo: $("#chatWindow").height()});

  });




  </script>
  {% endblock %}