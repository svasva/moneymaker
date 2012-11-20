class UsersController < ApplicationController
  def send_message
    begin
      args = params[:args] || []
      case params[:cmd]
      when 'PING'
        response = 'pong'
      when 'getItem'
        response = Item.find(args.first)
      when 'buyItem'
        user = User.find(params[:id])
        item_id, currency = args
        raise 'wrong arguments' unless item_id and currency
        raise 'wrong currency' unless %w(coins money).include? currency
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
      when 'getFlashLibs'
        response = []
        user = User.find(params[:id])
        local = (args[0] == 'true')
        FlashLib.where(social: user.social).each do |fl|
          response << fl.path(local)
        end
      else
        raise 'command unknown'
      end
    rescue => e
      response = { error: e.inspect }
    ensure
      render json: response
    end
  end
end
