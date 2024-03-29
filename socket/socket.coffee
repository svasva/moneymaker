socketserver = (app, server) ->
  sockjs = require 'sockjs'
  mongo = require 'mongoose'
  rest = require 'restless'
  if process.env.NODE_ENV is 'production'
    REST_URL = 'http://app.so14.org/api/'
    db = mongo.createConnection('localhost', 'moneymaker_prod')
  else
    REST_URL = 'http://localhost:3000/api/'
    db = mongo.createConnection('localhost', 'moneymaker_dev')

  SocketSchema = new mongo.Schema
    any: mongo.Schema.Types.Mixed
  Socket = db.model 'user_sockets', SocketSchema
  sockets = {}

  UserSchema = new mongo.Schema
    any: mongo.Schema.Types.Mixed
    online: Boolean
  User = db.model 'users', UserSchema

  setOnline = (user, online = true) ->
    user.online = online
    user.save()

  onConnect = (conn) ->
    conn.on "data", (message) ->
      console.log 'DATA RECEIVED: \n' + JSON.stringify message
      data = JSON.parse(message)
      if conn.token and conn.user
        # authenticated client
        onCommand(conn, data)
        setOnline conn.user
      else
        # have to authenticate client
        onAuth(conn, data)
    conn.on "close", ->
      if conn.token and conn.user
        setOnline(conn.user, false)

        delete sockets[conn.user.id][conn.token]
        # Socket.findByIdAndRemove conn.token
        console.log "#{conn.user.get('social')} user ##{conn.user.get('social_id')} disconnected"

  onAuth = (conn, data) ->
    Socket.findById data.token, (err, socket) ->
      if !socket
        sendResponse conn, data.requestId, {error: "socket not found: #{data.token}"}
        conn.close()
      else User.findById socket.get('user_id'), (err, user) ->
        if !user
          sendResponse conn, data.requestId, {error: "user not found: #{user}"}
          conn.close()
        else
          setOnline user
          conn.user = user
          conn.token = data.token
          sockets[user.id] = {} unless sockets[user.id]
          sockets[user.id][conn.token] = conn

          sendResponse conn, data.requestId, {success: 'connection established'}
          userString = "#{conn.user.get('social')}##{conn.user.get('social_id')}"
          console.log "user #{userString} connected"
          console.log "connections: " + Object.keys(sockets).length

  onCommand = (conn, data) ->
    url = REST_URL + "users/#{conn.user.id}/send_message"
    msg = {requestId: data.requestId, cmd: data.command, args: data.args}
    rest.post url, {data: msg}, (err, resp) ->
      sendResponse conn, data.requestId, resp
      console.log "POST #{url}:"
      console.log err, resp

  sendResponse = (conn, requestId, resp) ->
    console.log 'DATA SENT:\n' + JSON.stringify({requestId: requestId, response: resp})
    conn.write JSON.stringify({requestId: requestId, response: resp})

  db.once 'open', ->
    # Socket.collection.drop()
    sock = sockjs.createServer()
    sock.installHandlers(server, {prefix:'/socket'})
    sock.on "connection", onConnect
  return sockets

module.exports = socketserver
