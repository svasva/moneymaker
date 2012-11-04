routes = (app, sockets) ->
  app.get '/', (req, res) -> res.send 'nothing to see here'
  app.post '/sock/:id', (req, res) ->
    socket = sockets[req.params.id]
    socket.write JSON.stringify(req.body)
    res.send socket.token

module.exports = routes
