class UsersController < ApplicationController
  def send_message
    @args = params[:args]
    case params[:cmd]
    when 'PING'
      render json: 'pong'
    when 'getItem'
      @item = Item.find(@args.first)
      render json: @item
    when 'buyItem'
      begin
        user = User.find(params[:id])
        item_id, currency = @args
        raise 'wrong arguments' unless item_id and currency
        item = Item.find item_id
        useritem = user.buy_item item, currency.to_sym
        render json: useritem
      rescue => e
        render json: { error: e.inspect }
      end
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
