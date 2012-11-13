class UsersController < ApplicationController
  def send_message
    @user = User.find params[:id]
    @args = params[:args]
    case params[:cmd]
    when 'PING'
      render json: 'pong'
    when 'getItem'
      @item = Item.find(@args.first)
      render json: @item
    when 'getItems'
      @items = Item.all
      render json: @items
    else
      render json: {error: 'command unknown'}
    end
  end
end
