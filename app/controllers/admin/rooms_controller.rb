class Admin::RoomsController < Admin::BaseController
  respond_to :html, :json
  def edit
    @upgrades = Room.refs.where(room_type_id: resource.room_type_id).ne(id: resource.id).map { |upg|
      [upg.name, upg.id]
    }
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    resource.requirements['items'] ||= {}
    @req_items = resource.requirements['items'].map do |item_id, count|
      { id: item_id,
        name: Item.find(item_id).name,
        count: count }
    end
    resource.requirements['rooms'] ||= {}
    @req_rooms = resource.requirements['rooms'].map do |room_id, count|
      { id: room_id,
        name: Room.find(room_id).name,
        count: count }
    end
    resource.effects ||= {}
    @effects = resource.effects.map do |effect_id, count|
      { id: effect_id,
        name: I18n.t('item.effect_options.' + effect_id),
        count: count }
    end
    super
  end

  def new
    @upgrades = Room.all.map { |upg| [upg.name, upg.id] }
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    super
  end
end
