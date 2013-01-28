module AuthHelper
  def social_auth
    begin
      @social = params[:social]
      case @social
      when 'vkontakte'
        vk_auth
      when 'mailru'
        mailru_auth
      else
        raise 'unknown social'
      end
      @user = User.find_or_create_by(social: @social, social_id: @social_id)
      @user.update_attribute(:last_sign_in, Time.now)
      set_current_user @user
    rescue => e
      logger.error 'AUTH FAILED: ' + e.inspect
      render text: 'AUTH FAILED: ' + e.inspect
    end
  end

  def vk_auth
    @social_id = params[:viewer_id]
    key = SOCIAL['vkontakte']['app_id'] + "_"
    key += params[:viewer_id] + "_"
    key += SOCIAL['vkontakte']['app_secret']
    md5 = Digest::MD5.hexdigest(key)
    if params[:auth_key] != md5
      raise "auth failed, #{params[:auth_key]} != #{md5}"
    end
  end

  def mailru_auth
    @social_id = params[:vid]
    sig = params.delete :sig
    params.delete :controller
    params.delete :action
    req = params.reduce("") {|mem, item|
      mem + "#{item.keys.first}=#{items.values.first}"
    }
    md5 = Digest::MD5.hexdigest(req)
    raise "auth failed, #{sig} != #{md5}" if sig != md5
  end
end
