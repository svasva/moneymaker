class UsersController < ApplicationController
  def send_message
    begin
      args = params[:args] || []
      case params[:cmd]
      when 'PING'
        response = 'pong'
      when 'getUser'
        user = User.find params[:id]
        response = user.as_json(methods: [:rooms, :items])
      when 'getContent'
        response = GameContent.find(args.first)
      when 'buyContent'
        user = User.find(params[:id])
        content_id, currency = args
        raise 'wrong arguments' unless content_id and currency
        raise 'wrong currency' unless %w(coins money).include? currency
        content = GameContent.find(content_id)
        response = user.buy_content(content, currency.to_sym)
      when 'sellContent'
        sold = GameContent.find(args.first).sell
        raise 'item not sold' unless sold
        response = { success: 'item sold' }
      when 'getItems'
        response = Item.refs.as_json(methods: [:swf_url, :icon_url])
      when 'getItemTypes'
        response = ItemType.all.as_json(methods: [:icon_url])
      when 'getRoomTypes'
        response = RoomType.all.as_json(methods: [:icon_url])
      when 'getRooms'
        response = Room.refs.as_json(methods: [:swf_url, :icon_url])
      when 'startApplication'
        response = { success: 'application started' }
      when 'placeItem'
        room_id, item_id, x, y, rotation = args
        raise 'wrong params' unless room_id and item_id and x and y and rotation
        user = User.find params[:id]
        room = user.rooms.find room_id
        item = user.items.find item_id
        response = room.place_item item, x, y, rotation
      when 'getFlashLibs'
        response = []
        user = User.find(params[:id])
        local = (args[0] == 'true')
        FlashLib.where(social: user.social, active: true).each do |fl|
          response << fl.path(local)
        end
      when 'pushClient'
        user = User.find params[:id]
        user.send_client
        response = { success: 'client push initiated' }
      when 'serveClient'
        client_id, item_id = args
        raise 'wrong params' unless client_id and item_id
        user = User.find params[:id]
        client = Client.find client_id
        item = GameContent.find item_id
        item.update_attribute :client_id, client_id
        item.serve_client
        response = { success: 'client serve initiated' }
      when 'resetGame'
        User.find(params[:id]).destroy
        response = { success: 'user data has been deleted' }
      else
        raise params[:cmd] + ': command unknown'
      end
    rescue => e
      response = { error: e.inspect }
    ensure
      render json: response
    end
  end
end
