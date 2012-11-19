class UserRoom
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :room
  embedded_in :user
  embeds_many :user_items

  field :x, type: Integer, default: 0
  field :y, type: Integer, default: 0
end
