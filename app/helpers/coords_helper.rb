module CoordsHelper
  def slots_for(item, x, y)
    busy = []
    (y..y+item.size_y - 1).each do |y|
      (x..x+item.size_x - 1).each do |x|
        busy << [x, y]
      end
    end
    return busy
  end

  def map
    busy = busy_slots
    str = ''

    puts busy.inspect
    (room.size_y - 1).times do |y|
      (room.size_x - 1).times do |x|
        if busy.include? [x, y]
          str += '[]'
        else
          str += '__'
        end
      end
      str += "\n"
    end
    puts str
  end
end
