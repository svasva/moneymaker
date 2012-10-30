class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  belongs_to :item

  field :floor,             type: Integer,  default: -1
  field :x,                 type: Integer,  default: -1
  field :y,                 type: Integer,  default: -1
  field :status,            type: String,   default: 'standby'
end
