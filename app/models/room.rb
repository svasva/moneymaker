class Room < GameContent
  field :upgrade_id, type: String
  field :floor,      type: Integer, default: 1
  belongs_to :room_type
  validates_length_of :desc, maximum: 300
  validates_presence_of :room_type_id

  include CoordsHelper

  def busy_slots
    busy = []
    useritems = user.items.where room_id: self.id
    useritems.each do |uitem|
      busy.concat slots_for(uitem, uitem.x, uitem.y)
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
    raise 'no space for item' unless got_space? useritem, x, y
    useritem.update_attributes room_id: self.id, x: x, y: y
    return useritem.reload
  end
end
