socketserver = (app, server) ->
  sockjs = require('sockjs')
  mongo = require('mongoose')
  db = mongo.createConnection('localhost', 'moneymaker_dev')
  Socket = db.model("user_sockets", new mongo.Schema(any: {}))
  User = db.model("users", new mongo.Schema(any: {}))

  db.once 'open', ->
    sock = sockjs.createServer()
    sock.installHandlers(server, {prefix:'/socket'})
    sockets = {}

    sock.on "connection", (conn) ->
      conn.on "data", (message) ->
        data = JSON.parse(message)
        unless conn.token
          Socket.findById data.token, (err, socket) ->
            if !socket then conn.write(JSON.stringify(error: 'socket not found: ' + data.token))
            else User.findById socket.get('user_id'), (err, user) ->
              if !user then conn.write(JSON.stringify(error: 'user not found'))
              else
                conn.user = user
                conn.token = data.token
                sockets[conn.token] = conn
                conn.write "welcome, #{conn.user.get('social')}##{conn.user.get('social_id')}"
                console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} connected"
                console.log "connections: " + Object.keys(sockets).length
      conn.on "close", ->
        delete sockets[conn.token]
        Socket.findByIdAndRemove conn.token, (a, b) -> console.log a, b
        console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} disconnected"
        console.log "connections: " + Object.keys(sockets).length

module.exports = socketserver
