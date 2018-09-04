var mongoose = require('mongoose'),
    Schema = mongoose.Schema, 
    _ = require('underscore'), 
    moment = require('moment');

var threadSchema = mongoose.Schema({
    date: { type: Date, default: Date.now, expire: 3600 },
    code: String,
    messages: [{ type: Schema.Types.ObjectId, ref: 'Message' }],
    trends: [Date]
}, {
    timestamps: true
}).index({
    code: 'text'
});

threadSchema.pre('save', function (next) {
    var self = this;
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 6; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    self.code = text;
    next();
});

threadSchema
.virtual('trending')
.get(function () {
    var self = this;
    var dataStr = '';
    var groups = _.groupBy(self.trends, function (date) {
        return moment(date).startOf('hour').format();
    });

    for (var key in groups) {
        if (groups.hasOwnProperty(key)) {
            dataStr += groups[key].length + ',';
        }
    }

    dataStr = dataStr.slice(0, -1);

    return dataStr;
});

threadSchema.set('toObject', { getters: true });
threadSchema.set('toJSON', { getters: true });

module.exports = mongoose.model('Thread', threadSchema);