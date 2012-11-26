class RoomType < ItemType
  PLACEMENT_OPTIONS = %w(any ground underground onground)
  has_many :rooms
end
