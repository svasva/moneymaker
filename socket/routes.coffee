routes = (app, sockets) ->
  app.get '/', (req, res) -> res.send 'nothing to see here'
  app.post '/sock/:id', (req, res) ->
    socket = sockets[req.params.id]
    if socket
      socket.write JSON.stringify(req.body)
      res.send socket.token
    else
      res.writeHead(404, {"Content-Type": "text/plain"})
      res.write '404 not found'
      res.end()

module.exports = routes
