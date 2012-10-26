class Item
  include Mongoid::Document
  field :name,              type: String
  field :money_cost,        type: Integer, default: 0
  field :coins_cost,        type: Integer, default: 0
  field :size_x,            type: Integer, default: 1
  field :size_y,            type: Integer, default: 1
  field :reputation_bonus,  type: Integer, default: 0

  validates_presence_of :name, :size_x, :size_y
end
