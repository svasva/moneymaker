class Admin::ItemsController < InheritedResources::Base
  def edit
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    super
  end

  def new
    @rooms = Room.where(startup: true).map {|r| [r.name, r.id]}
    super
  end
end
