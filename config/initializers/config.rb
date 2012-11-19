SOCIAL = YAML.load_file("#{Rails.root}/config/social.yml")[Rails.env]
if Rails.env.production?
  SOCKET_API = 'http://socket.so14.org/sock'
  SOCKET_URL = 'ws://192.168.1.242:9999/socket/0/0/websocket'
else
  SOCKET_API = 'http://localhost:9999/sock'
  SOCKET_URL = 'ws://app.so14.org/socket/0/0/websocket'
end
