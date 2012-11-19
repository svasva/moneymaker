class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  belongs_to :item

  field :x,                 type: Integer,  default: -1
  field :y,                 type: Integer,  default: -1
  field :status,            type: String,   default: 'standby'
  field :room_id,           type: String

  index({x: 1, y: 1})
end
