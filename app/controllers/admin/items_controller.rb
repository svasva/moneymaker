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
  protected
  def collection
    @items ||= end_of_association_chain.where(_type: nil)
  end
end
