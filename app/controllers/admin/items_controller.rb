class Admin::ItemsController < InheritedResources::Base
  def edit
    @upgrades = Item.where(type: resource.type).ne(id: resource.id).map { |upg|
      [upg.name, upg.id]
    }
    super
  end

  def new
    @upgrades = Item.all.map { |upg| [upg.name, upg.id] }
    super
  end
end
