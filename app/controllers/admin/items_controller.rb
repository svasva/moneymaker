class Admin::ItemsController < InheritedResources::Base
  before_filter :setup_vars
  def setup_vars
    @startup_rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |t| [t.name, t.id] }
    @item_types = ItemType.all.map { |t| [t.name, t.id] }
    @items_sel = Item.all.map {|r| [r.name, r.id]}
    @rooms_sel = Room.all.map {|r| [r.name, r.id]}
    return true
  end

  def edit
    resource.requirements['items'] ||= {}
    @startup_rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
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
end
