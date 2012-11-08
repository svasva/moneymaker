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

app.get( "/crossdomain.xml", function (req, res) {
  var xml = '<?xml version="1.0"?>\n<!DOCTYPE cross-domain-policy SYSTEM' +
            ' "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">\n<cross-domain-policy>\n';
      xml += '<allow-access-from domain="*" to-ports="*"/>\n'+
             '<site-control permitted-cross-domain-policies="all"/>\n';
      xml += '</cross-domain-policy>\n';

  req.setEncoding('utf8');
  res.writeHead( 200, {'Content-Type': 'text/xml'} );
  res.end( xml );
});

sockets = require('./socket')(app, server);
require('./routes')(app, sockets);

