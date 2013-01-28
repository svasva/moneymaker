class HomeController < ApplicationController
  include AuthHelper
  before_filter :social_auth

  def index
    @greeting = Greeting.get_random
    @socket_id = current_user.user_sockets.create.id
    @swfpath = Swfclient.active.swf.to_s
    @flashvars = {
      token: @socket_id,
      greeting: @greeting,
      socket_url: SOCKET_URL,
      social: @social,
      content_url: CONTENT_URL
    }.map {|k,v| URI.escape "#{k}=#{v}"}.join '&'
    render :index, layout: false
  end
end
