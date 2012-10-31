require('coffee-script');

var express = require('express');
var app = express();
var server = require('http').createServer(app);
server.listen(9999, '0.0.0.0');

app.get('/', function(req, res) {
  res.send('nothing to see here');
});

require('./socket')(app, server);

