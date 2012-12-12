class GameContent
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :name,         type: String
  field :desc,         type: String

  field :money_cost,   type: Integer
  field :coins_cost,   type: Integer
  field :sell_cost,    type: Integer

  field :size_x,       type: Integer, default: 1
  field :size_y,       type: Integer, default: 1
  field :height,       type: Float,   default: 1
  field :x,            type: Integer
  field :y,            type: Integer

  field :startup,      type: Boolean, default: false
  field :startup_x,    type: Integer
  field :startup_y,    type: Integer

  field :order,        type: Integer
  field :reference_id, type: String

  field :requirements, type: Hash,    default: {items: {}, rooms: {}}
  field :rewards,      type: Hash,    default: {}
  field :effects,      type: Hash,    default: {}

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader

  validates_presence_of :name, :desc, :order
  validates_presence_of :size_x, :size_y, :height

  index({x: 1, y: 1}) # index items coordinates
  index({user_id: 1}) # index items user_id

  scope :refs, where(user_id: nil)

  # update referenced items, notify client
  after_update :update_refs, :update_client

  def update_client
    return true unless self.user_id
    message = {
      requestId: -2, # item update
      response: { id: self.id, changes: self.changes }
    }.to_json
    user.send_message message
  end

  # WARN: EXPENSIVE, DISABLE IN PRODUCTION
  def update_refs
    return true if self.user_id or changes.has_key? :user_id
    fields = self.attributes.select {|k,v| changes.keys.include? k.to_sym}
    self.references.update(fields) unless self.user_id
  end

  # item this one is based on
  def reference
    GameContent.where(id: self.reference_id).first
  end

  # items based on this one
  def references
    GameContent.where reference_id: self.id
  end

  def add_to_user(user_id, x = nil, y = nil)
    obj = self.class.new self.attributes
    obj.reference_id = (self.reference_id or self.id)
    obj.user_id = user_id
    obj.x, obj.y = x, y
    obj.save
    obj
  end

  def sell
    return false unless self.user_id
    if self.sell_cost and self.sell_cost > 0
      self.user.inc :coins, self.sell_cost
    end
    self.destroy
  end
end
