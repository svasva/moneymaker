class UserRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  include CoordsHelper

  belongs_to :room
  embedded_in :user

  field :x, type: Integer, default: 0
  field :y, type: Integer, default: 0

  def busy_slots
    busy = []
    useritems = user.user_items.where room_id: self.id
    useritems.each do |uitem|
      busy.concat slots_for(uitem.item, uitem.x, uitem.y)
    end
    return busy
  end

  def got_space?(item, x, y)
    return false if x < 0 or y < 0
    return false if x + item.size_x - 1 > self.size_x
    return false if y + item.size_y - 1 > self.size_y
    return (busy_slots & slots_for(item, x, y)).empty?
  end

  def place_item(useritem, x, y)
    raise 'no space for item' unless got_space? useritem.item, x, y
    useritem.update_attributes room: self, x: x, y: y
    return useritem.reload
  end
end
