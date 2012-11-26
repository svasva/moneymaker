class Admin::ItemsController < InheritedResources::Base
  def edit
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |t| [t.name, t.id] }
    @item_types = ItemType.all.map { |t| [t.name, t.id] }
    super
  end

  def new
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |t| [t.name, t.id] }
    @item_types = ItemType.all.map { |t| [t.name, t.id] }
    super
  end
end
