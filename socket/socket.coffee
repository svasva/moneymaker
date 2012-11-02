socketserver = (app, server) ->
  sockjs = require 'sockjs'
  mongo = require 'mongoose'
  rest = require 'restless'
  db = mongo.createConnection('localhost', 'moneymaker_dev')
  Socket = db.model("user_sockets", new mongo.Schema(any: {}))
  User = db.model("users", new mongo.Schema(any: {}))
  sockets = {}

  db.once 'open', ->
    Socket.collection.drop()
    sock = sockjs.createServer()
    sock.installHandlers(server, {prefix:'/socket'})

    sock.on "connection", (conn) ->
      conn.on "data", (message) ->
        console.log 'DATA RECEIVED: \n' + message
        data = JSON.parse(message)
        if conn.token and conn.user
          # authenticated client
          switch data.command
            when 'ping'
              msg = {cmd: 'PING'}
              rest.post "http://moneymaker.dev/api/users/#{conn.user.id}/send_message", {data: msg}, (err, data) ->
                console.log "POST http://moneymaker.dev/api/users/#{conn.user.id}/send_message:"
                console.log err, data
        else
          # have to authenticate client
          Socket.findById data.token, (err, socket) ->
            if !socket then conn.write(JSON.stringify(error: 'socket not found: ' + data.token))
            else User.findById socket.get('user_id'), (err, user) ->
              if !user then conn.write(JSON.stringify(error: 'user not found'))
              else
                conn.user = user
                conn.token = data.token
                sockets[conn.token] = conn
                conn.write "welcome, #{conn.user.get('social')}##{conn.user.get('social_id')}, sockid: #{conn.token}"
                console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} connected"
                console.log "connections: " + Object.keys(sockets).length
      conn.on "close", ->
        if conn.token
          delete sockets[conn.token]
          Socket.findByIdAndRemove conn.token
          console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} disconnected"
          console.log "connections: " + Object.keys(sockets).length
  sockets

module.exports = socketserver
