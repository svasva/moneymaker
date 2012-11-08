class HomeController < ApplicationController
  before_filter :social_auth

  def index
    @greeting = Greeting.all.sample
    @socket_id = current_user.user_sockets.create.id
  end

  def social_auth
    begin
      @social = params[:social]
      case @social
      when 'vkontakte'
        @social_id = params[:viewer_id]
        key = Digest::MD5.hexdigest("#{SOCIAL['vkontakte']['app_id']}_#{params[:viewer_id]}_#{SOCIAL['vkontakte']['app_secret']}")
        raise "auth failed, #{params[:auth_key]} != #{key}" unless params[:auth_key] == key
      else
        raise 'unknown social'
      end
      @user = User.find_or_create_by(social: @social, social_id: @social_id)
      @user.update_attribute(:last_sign_in, Time.now)
      set_current_user @user
    rescue => e
      logger.error 'AUTH ERROR: ' + e.message
      render text: 'auth failed'
    end
  end
end
