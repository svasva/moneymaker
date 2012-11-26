class Room < Item
  field :upgrade_id, type: String
  belongs_to :room_type
end
