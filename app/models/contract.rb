class Contract
  include Mongoid::Document

  embedded_in :item

  field :name,              type: String
  field :requirements,      type: Hash
  field :rewards,           type: Hash
  field :execution_time,    type: Integer
end
