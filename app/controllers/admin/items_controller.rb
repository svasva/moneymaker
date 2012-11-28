class Admin::ItemsController < InheritedResources::Base
  def edit
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |t| [t.name, t.id] }
    @item_types = ItemType.all.map { |t| [t.name, t.id] }
    @items = Item.ne(id: resource.id).map {|r| [r.name, r.id]}
    @req_items = resource.requirements['items'].map do |item_id, count|
      {
        id: item_id,
        name: Item.find(item_id).name,
        count: count
      }
    end
    super
  end

  def new
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |t| [t.name, t.id] }
    @item_types = ItemType.all.map { |t| [t.name, t.id] }
    @items = Item.all.map {|r| [r.name, r.id]}
    super
  end
end
