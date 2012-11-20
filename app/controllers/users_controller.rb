class UsersController < ApplicationController
  def send_message
    @args = params[:args]
    case params[:cmd]
    when 'PING'
      render json: 'pong'
    when 'getItem'
      @item = Item.find(@args.first)
      render json: @item
    when 'sellItem'
      begin
        @item = UserItem.find(@args.first).sell
        render json: { success: 'item sold' }
      rescue => e
        render json: { error: e.inspect }
      end
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
