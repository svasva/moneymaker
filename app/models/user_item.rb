class UserItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  belongs_to :item
  belongs_to :user_room

  field :x,                 type: Integer,  default: -1
  field :y,                 type: Integer,  default: -1
  field :status,            type: String,   default: 'standby'
  field :rotation,          type: Integer,  default: 0

  index({x: 1, y: 1})

  def sell
    if self.sell_cost and self.sell_cost > 0
      self.user.inc :coins, self.sell_cost
    end
    self.destroy
  end
end
