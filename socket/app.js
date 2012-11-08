require('coffee-script');

var express = require('express');
var app = express();
app.configure(function(){
  app.set('port', process.env.PORT || 9999);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.logger('dev'));
  app.use(express.methodOverride());
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

var server = require('http').createServer(app);
server.listen(app.get('port'));

sockets = require('./socket')(app, server);
require('./routes')(app, sockets);

