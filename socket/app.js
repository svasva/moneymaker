require('coffee-script');

var express = require('express');
var app = express();
var server = require('http').createServer(app);
server.listen(9999, '0.0.0.0');
app.use(express.bodyParser());
sockets = require('./socket')(app, server);
require('./routes')(app, sockets);
