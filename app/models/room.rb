class Room < Item
  field :upgrade_id, type: String
  belongs_to :room_type
  validates_length_of :desc, maximum: 300
  validates_presence_of :room_type_id
end
