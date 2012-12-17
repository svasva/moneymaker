routes = (app, sockets) ->
  app.get '/', (req, res) -> res.send 'nothing to see here'
  app.post '/sock/:id', (req, res) ->
    userSockets = sockets[req.params.id]
    if userSockets and Object.keys(userSockets).length
      console.log req.body
      socketIds = []
      for socketId, socket of userSockets
        socket.write JSON.stringify(req.body)
        socketIds.push socketId
      res.send JSON.stringify(socketIds)
    else
      res.writeHead(404, {"Content-Type": "text/plain"})
      res.write '404 not found'
      res.end()

module.exports = routes
