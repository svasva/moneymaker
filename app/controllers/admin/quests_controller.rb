class Admin::QuestsController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name desc)
    true
  end

  def edit
    resource.requirements['items'] ||= {}
    @req_items = resource.requirements['items'].map do |item_id, count|
      { id: item_id,
        name: Item.find(item_id).name,
        count: count }
    end
    resource.complete_requirements['items'] ||= {}
    @compl_req_items = resource.complete_requirements['items'].map do |item_id, count|
      { id: item_id,
        name: Item.find(item_id).name,
        count: count }
    end
  end
end
