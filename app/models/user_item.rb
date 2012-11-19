class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user_room
  belongs_to :item

  field :x,                 type: Integer,  default: -1
  field :y,                 type: Integer,  default: -1
  field :status,            type: String,   default: 'standby'

  index({x: 1, y: 1})
end
