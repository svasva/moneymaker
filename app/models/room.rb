class Room < Item
  field :upgrade_id, type: String
  embeds_one :room_type
end
