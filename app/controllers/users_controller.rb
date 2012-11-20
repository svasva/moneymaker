class UsersController < ApplicationController
  def send_message
    begin
      args = params[:args]
      case params[:cmd]
      when 'PING'
        response = 'pong'
      when 'getItem'
        response = Item.find(args.first)
      when 'buyItem'
        user = User.find(params[:id])
        item_id, currency = args
        raise 'wrong arguments' unless item_id and currency
        item = Item.find(item_id)
        response = user.buy_item(item, currency.to_sym)
      when 'sellItem'
        item = UserItem.find(args.first).sell
        raise 'item not sold' unless item
        response = { success: 'item sold' }
      when 'getItems'
        response = Item.all
      when 'startApplication'
        response = { success: 'application started' }
      else
        raise 'command unknown'
      end
      render json: response
    rescue => e
      render json: { error: e.inspect }
    end
  end
end
