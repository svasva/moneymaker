class Admin::RoomsController < InheritedResources::Base
  def edit
    @upgrades = Room.where(type: resource.type).ne(id: resource.id).map { |upg|
      [upg.name, upg.id]
    }
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    super
  end

  def new
    @upgrades = Room.all.map { |upg| [upg.name, upg.id] }
    @room_types = RoomType.all.map { |rt| [rt.name, rt.id] }
    super
  end
end
