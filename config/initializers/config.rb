SOCIAL = YAML.load_file("#{Rails.root}/config/social.yml")[Rails.env]
if Rails.env.production?
  SOCKET_API = 'http://ws.so14.org/sock'
  SOCKET_URL = 'ws://ws.so14.org/socket/websocket'
  CONTENT_URL = 'http://app.so14.org'
else
  SOCKET_API = 'http://192.168.1.242:9999/sock'
  SOCKET_URL = 'ws://192.168.1.242:9999/socket/websocket'
  CONTENT_URL = 'http://192.168.1.242:3000'
end
SOCIAL_NETS = %w(vkontakte mailru odnoklassniki facebook)
