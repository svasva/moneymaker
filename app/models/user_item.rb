class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  belongs_to :item

  field :floor,             type: Integer
  field :x,                 type: Integer
  field :y,                 type: Integer
  field :status,            type: String
  field :contract_id,       type: Integer
  field :contract_ends_on,  type: DateTime
end
