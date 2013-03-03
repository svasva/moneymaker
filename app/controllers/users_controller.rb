class UsersController < ApplicationController
  def send_message
    begin
      args = params[:args] || []
      user = User.find params[:id]
      case params[:cmd]
      when 'PING'
        response = 'pong'
      when 'getUser'
        response = user.as_json(methods: [:rooms, :items, :levelnumber, :nextlevel, :min_rep, :capacity])
      when 'getContent'
        response = GameContent.find(args.first)
      when 'getContracts'
        response = Contract.refs.as_json(methods: [:icon_url])
      when 'buyContent'
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
      when 'getQuests'
        response = Quest.all
      when 'getAvailableQuests'
        response = user.available_quests.map &:id
      when 'acceptQuest'
        Quest.find(args.first).accept_for(user)
        response = { success: 'quest accepted' }
      when 'completeQuest'
        Quest.find(quest_id).complete_for(user)
        response = { success: 'quest complete' }
      when 'getContracts'
        response = Contract.all
      when 'getAvailableContracts'
        response = Contract.available_for(user).map &:id
      when 'buyContract'
        Contract.find(args.first).start_for user
        response = { success: 'contract started' }
      when 'startApplication'
        user.start_game
        response = { success: 'application started' }
      when 'itemEncashment'
        item_id = args[0]
        raise 'wrong item_id' unless item = Item.find(item_id)
        item.do_encashment
        response = { success: 'encashment done' }
      when 'startClientService'
        item_id, client_id, operation_id = args
        raise 'wrong item_id' unless item = Item.find(item_id)
        raise 'wrong client_id' unless client = Client.find(client_id)
        case item.state
        when 'empty', 'full'
          # TODO: move this out of controller
          if user.reputation >= client.reputation
            user.update_attribute :reputation, user.reputation - client.reputation
          end
          response = { no_service: "item is #{item.state}", item_id: item_id }
        when 'standby'
          item.update_attributes client_id: client_id, operation_id: operation_id
          item.serve_client
          response = { success: 'service started', item_id: item_id }
        else
          raise 'item not ready'
        end
      when 'placeRoom'
        room_id, floor, x, y, rotation = args
        room = user.rooms.find room_id
        room.update_attributes floor: floor.to_i, x: x.to_i, y: y.to_i, rotation: rotation.to_i
        response = { success: 'room placement done' }
      when 'placeItem'
        room_id, item_id, x, y, rotation = args
        raise 'wrong params' unless room_id and item_id and x and y and rotation
        room = user.rooms.find room_id
        item = user.items.find item_id
        response = room.place_item item, x, y, rotation
      when 'getFlashLibs'
        response = []
        local = (args[0] == 'true')
        FlashLib.where(social: user.social, active: true).each do |fl|
          response << fl.path(local)
        end
      when 'pushClient'
        user.send_client
        response = { success: 'client push initiated' }
      when 'overdueClient'
        client_id, wait_time = args
        raise 'wrong params' unless clinet_id and wait_time
        EventHandler.trigger user, :overdue_client, {client: Client.find(client_id), wait_time: wait_time.to_i}
        response = { success: 'event queued' }
      when 'getShopCatalog'
        shop = {}
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
        user.destroy
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
