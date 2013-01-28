class Admin::BranchLevelsController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name capacity cost profit)
    true
  end

  def edit
    resource.requirements['items'] ||= {}
    @req_items = resource.requirements['items'].map do |item_id, count|
      { id: item_id,
        name: Item.find(item_id).name,
        count: count }
    end
    resource.requirements['rooms'] ||= {}
    @req_rooms = resource.requirements['rooms'].map do |room_id, count|
      { id: room_id,
        name: Room.find(room_id).name,
        count: count }
    end
    super
  end
end
