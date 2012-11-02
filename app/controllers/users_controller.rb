class UsersController < ApplicationController
  def send_message
    @user = User.find params[:id]
    case params[:cmd]
    when 'PING'
      render text: "PONG to #{@user.social}##{@user.social_id}"
    end
  end
end
