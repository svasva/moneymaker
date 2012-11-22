class Item
  include Mongoid::Document

  embeds_many :contracts

  field :name,              type: String
  field :desc,              type: String
  field :type,              type: String
  field :money_cost,        type: Integer, default: 0
  field :coins_cost,        type: Integer, default: 0
  field :sell_cost,         type: Integer, default: 0
  field :size_x,            type: Integer, default: 1
  field :size_y,            type: Integer, default: 1
  field :reputation_bonus,  type: Integer, default: 0
  field :startup,           type: Boolean, default: false
  field :startup_x,         type: Integer
  field :startup_y,         type: Integer

  field :requirements,      type: Hash
  field :rewards,           type: Hash
  field :effects,           type: Hash

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader

  validates_presence_of :name, :size_x, :size_y

  default_scope where(_type: nil)
end
