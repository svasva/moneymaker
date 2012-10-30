class Item
  include Mongoid::Document

  embeds_many :contracts

  field :name,              type: String
  field :item_type,         type: String
  field :money_cost,        type: Integer, default: 0
  field :coins_cost,        type: Integer, default: 0
  field :sell_cost,         type: Integer, default: 0
  field :size_x,            type: Integer, default: 1
  field :size_y,            type: Integer, default: 1
  field :reputation_bonus,  type: Integer, default: 0

  field :requirements,      type: Hash
  field :rewards,           type: Hash

  has_one :upgrade, class_name: 'Item'

  validates_presence_of :name, :size_x, :size_y
end
