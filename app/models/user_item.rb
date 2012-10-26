class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  belongs_to :item

  field :floor,             type: Integer,  default: -1
  field :x,                 type: Integer,  default: -1
  field :y,                 type: Integer,  default: -1
  field :status,            type: String,   default: ''
  field :contract_id,       type: Integer
  field :contract_ends_on,  type: DateTime
end
