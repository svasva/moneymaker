SOCIAL = YAML.load_file("#{Rails.root}/config/social.yml")[Rails.env]
if Rails.env.production?
  SOCKET_URL = "http://socket.so14.org/sock/"
else
  SOCKET_URL = "http://localhost:9999/sock/"
end
