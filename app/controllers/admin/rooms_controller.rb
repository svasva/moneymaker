class Admin::RoomsController < InheritedResources::Base
  def edit
    @upgrades = Room.where(type: resource.type).ne(id: resource.id).map { |upg|
      [upg.name, upg.id]
    }
    super
  end

  def new
    @upgrades = Room.all.map { |upg| [upg.name, upg.id] }
    super
  end
end
