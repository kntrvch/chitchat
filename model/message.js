var mongoose = require('mongoose'), 
    timeAgo = require('node-time-ago');

var messageSchema = mongoose.Schema({
    author: String, 
    message: String, 
    date: {
        type: Date,
        default: Date.now, 
        get: timeAgo
    },
    threadCode: String
});

messageSchema.set('toObject', { getters: true });
messageSchema.set('toJSON', { getters: true });

module.exports = mongoose.model('Message', messageSchema);