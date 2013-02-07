class Admin::ContractsController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name coins_cost money_cost)
    true
  end

  def edit
    resource.requirements['items'] ||= {}
    @req_items = resource.requirements['items'].map do |item_id, count|
      { id: item_id,
        name: Item.find(item_id).name,
        count: count }
    end
  end
end
