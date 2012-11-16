class UsersController < ApplicationController
  def send_message
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
    when 'startApplication'
      render json: {success: 'application started'}
    else
      render json: {error: 'command unknown'}
    end
  end
end
