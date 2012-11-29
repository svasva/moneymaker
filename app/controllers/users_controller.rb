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
        sold = UserItem.find(args.first).sell
        raise 'item not sold' unless sold
        response = { success: 'item sold' }
      when 'getItems'
        response = Item.all.as_json(methods: [:swf_url, :icon_url])
      when 'getItemTypes'
        response = ItemType.all.as_json(methods: [:icon_url])
      when 'getRoomTypes'
        response = RoomType.all.as_json(methods: [:icon_url])
      when 'getRooms'
        response = Room.all
      when 'getRoom'
        response = Room.find(args.first)
      when 'startApplication'
        response = { success: 'application started' }
      when 'placeItem'
        room_id, item_id, x, y = args
        raise 'wrong params' unless room_id and item_id and x and y
        user = User.find params[:id]
        room = user.user_rooms.find room_id
        item = user.user_items.find item_id
        response = room.place_item item, x, y
      when 'getFlashLibs'
        response = []
        user = User.find(params[:id])
        local = (args[0] == 'true')
        FlashLib.where(social: user.social, active: true).each do |fl|
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
