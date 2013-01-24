class Admin::BranchesController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name desc level)
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
    resource.effects ||= {}
    @effects = resource.effects.map do |effect_id, count|
      { id: effect_id,
        name: I18n.t('item.effect_options.' + effect_id),
        count: count }
    end
    super
  end
end
