require('coffee-script');

var express = require('express');
var app = express();
var server = require('http').createServer(app);
server.listen(9999, '0.0.0.0');
app.use(express.bodyParser());
app.get('/', function(req, res) {
  res.send('nothing to see here');
});

sockets = require('./socket')(app, server);
app.post('/sock/:id', function(req, res) {
  var sid = req.params.id,
      socket = sockets[sid];
  socket.write(JSON.stringify(req.body));
  res.send(sid);
});
