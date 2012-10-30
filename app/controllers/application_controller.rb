class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  helper_method :set_current_user

  protected

  def current_user
    @current_user
  end

  def set_current_user(user)
    @current_user = user
  end
end
