module AuthHelper
  def social_auth
    begin
      @social = params[:social]
      case @social
      when 'vkontakte'
        vk_auth
      when 'mailru'
        mailru_auth
      when 'facebook'
        facebook_auth
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
    params.delete :social
    req = ""
    params.sort.each {|k,v| req += "#{k}=#{v}"}
    md5 = Digest::MD5.hexdigest(req+SOCIAL['mailru']['app_secret'])
    raise "auth failed, #{sig} != #{md5}; #{req}" if sig != md5
  end

  def facebook_auth
    fb_data = parse_facebook(params[:signed_request], SOCIAL['facebook']['app_secret'])
    @social_id = fb_data['user_id']
    redirect_to "https://www.facebook.com/dialog/oauth?client_id=#{SOCIAL['facebook']['app_id']}&redirect_uri=http://apps.facebook.com/#{SOCIAL['facebook']['app_namespace']}/" unless @social_id
  end

  def parse_facebook(signed_request, secret, max_age=3600)
    encoded_sig, encoded_envelope = signed_request.split('.', 2)
    envelope = JSON.parse(base64_url_decode(encoded_envelope))
    algorithm = envelope['algorithm']

    raise 'Invalid request. (Unsupported algorithm.)' \
      if algorithm != 'HMAC-SHA256'

    raise 'Invalid request. (Too old.)' \
      if envelope['issued_at'] < Time.now.to_i - max_age

    raise 'Invalid request. (Invalid signature.)' \
      if base64_url_decode(encoded_sig) != OpenSSL::HMAC.hexdigest('sha256', secret, encoded_envelope).split.pack('H*')

    envelope
  end

  def base64_url_decode(str)
    str += '=' * (4 - str.length.modulo(4))
    Base64.decode64(str.tr('-_','+/'))
  end
end
