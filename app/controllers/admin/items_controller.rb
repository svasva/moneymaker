class Admin::ItemsController < InheritedResources::Base
  def edit
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    super
  end

  def new
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    super
  end
end
