class UsersController < ApplicationController
  def send_message
    begin
      args = params[:args] || []
      case params[:cmd]
      when 'PING'
        response = 'pong'
      when 'getUser'
        user = User.find params[:id]
        response = user.as_json(methods: [:rooms, :items, :levelnumber, :nextlevel, :min_rep, :capacity])
      when 'getContent'
        response = GameContent.find(args.first)
      when 'getContracts'
        response = Contract.refs.as_json(methods: [:icon_url])
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
        response = Item.refs.as_json(methods: [:swf_url, :icon_url, :_type])
      when 'getItemTypes'
        response = ItemType.all.as_json(methods: [:icon_url])
      when 'getRoomTypes'
        response = RoomType.all.as_json(methods: [:icon_url])
      when 'getRooms'
        response = Room.refs.as_json(methods: [:swf_url, :icon_url])
      when 'startApplication'
        user = User.find params[:id]
        user.start_game
        response = { success: 'application started' }
      when 'itemEncashment'
        user = User.find params[:id]
        item_id = args[0]
        raise 'wrong item_id' unless item = Item.find(item_id)
        item.do_encashment
        response = { success: 'encashment done' }
      when 'startClientService'
        user = User.find params[:id]
        item_id, client_id, operation_id = args
        raise 'wrong item_id' unless item = Item.find(item_id)
        raise 'wrong client_id' unless client = Client.find(client_id)
        case item.state
        when 'empty', 'full'
          # TODO: move this out of controller
          if user.reputation >= client.reputation
            user.update_attribute :reputation, user.reputation - client.reputation
          end
          response = { no_service: "item is #{item.state}" }
        when 'standby'
          item.update_attributes client_id: client_id, operation_id: operation_id
          item.serve_client
          response = { success: 'service started' }
        else
          raise 'item not ready'
        end
      when 'placeRoom'
        room_id, x, y, rotation = args
        user = User.find params[:id]
        room = user.rooms.find room_id
        room.update_attributes x: x.to_i, y: y.to_i, rotation: rotation.to_i
        response = { success: 'room placement done' }
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
      when 'overdueClient'
        user = User.find params[:id]
        client_id, wait_time = args
        raise 'wrong params' unless clinet_id and wait_time
        EventHandler.trigger user, :overdue_client, {client: Client.find(client_id), wait_time: wait_time.to_i}
        response = { success: 'event queued' }
      when 'getShopCatalog'
        shop = {}
        user = User.find(params[:id])
        shop[:main] = RoomType.all.as_json(methods: [:ref_items, :ref_rooms])
        shop[:warehouse] = user.items.store.map(&:id)
        shop[:premium] = [
          {name: 'money1', desc: 'money money money', social_price: 10, money: 100, icon: Item.first.icon_url},
          {name: 'money2', desc: 'money money money', social_price: 20, money: 200, icon: Item.first.icon_url},
          {name: 'money3', desc: 'money money money', social_price: 30, money: 300, icon: Item.first.icon_url},
          {name: 'money4', desc: 'money money money', social_price: 40, money: 400, icon: Item.first.icon_url},
          {name: 'money5', desc: 'money money money', social_price: 50, money: 500, icon: Item.first.icon_url},
          {name: 'money6', desc: 'money money money', social_price: 60, money: 600, icon: Item.first.icon_url}
        ]
        shop[:bonus] = Item.in(item_type_id: ItemType.where(placement: 'none').map(&:id)).map(&:id)
        response = shop
      when 'resetGame'
        User.find(params[:id]).destroy
        response = { success: 'user data has been deleted' }
      else
        raise params[:cmd] + ': command unknown'
      end
    rescue => e
      response = { error: e.inspect, stack: e.backtrace }
    ensure
      render json: response
    end
  end
end
