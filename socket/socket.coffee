socketserver = (app, server) ->
  sockjs = require 'sockjs'
  mongo = require 'mongoose'
  rest = require 'restless'
  db = mongo.createConnection('localhost', 'moneymaker_dev')
  # db = mongo.createConnection('mongodb://nodejitsu:6a3fefbf70f8e0b9e7245cce2de5e888@alex.mongohq.com:10088/nodejitsudb27089455908')
  Socket = db.model("user_sockets", new mongo.Schema(any: {}))
  User = db.model("users", new mongo.Schema(any: {}))
  sockets = {}

  onConnect = (conn) ->
    conn.on "data", (message) ->
      console.log 'DATA RECEIVED: \n' + message
      data = JSON.parse(message)
      if conn.token and conn.user
        # authenticated client
        onCommand(conn, data)
      else
        # have to authenticate client
        onAuth(conn, data)
    conn.on "close", ->
      if conn.token
        delete sockets[conn.token]
        Socket.findByIdAndRemove conn.token
        console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} disconnected"
        console.log "connections: " + Object.keys(sockets).length

  onAuth = (conn, data) ->
    Socket.findById data.token, (err, socket) ->
      if !socket
        conn.write JSON.stringify(error: "socket not found: #{data.token}")
      else User.findById socket.get('user_id'), (err, user) ->
        if !user then conn.write JSON.stringify(error: "user not found: #{user}")
        else
          conn.user = user
          conn.token = data.token
          sockets[conn.token] = conn
          userString = "#{conn.user.get('social')}##{conn.user.get('social_id')}"
          conn.write "welcome, #{userString}, sockid: #{conn.token}"
          console.log "user #{userString} connected"
          console.log "connections: " + Object.keys(sockets).length

  onCommand = (conn, data) ->
    switch data.command
      when 'ping'
        url = "http://moneymaker.dev/api/users/#{conn.user.id}/send_message"
        msg = {cmd: 'PING'}
        rest.post url, {data: msg}, (err, data) ->
          console.log "POST #{url}:"
          console.log err, data

  db.once 'open', ->
    Socket.collection.drop()
    sock = sockjs.createServer()
    sock.installHandlers(server, {prefix:'/socket'})
    sock.on "connection", onConnect
  return sockets

module.exports = socketserver
