class RoomType
  include Mongoid::Document
  field :name,       type: String
  field :placement,  type: String
  field :unique,     type: Boolean, default: false
  field :timed,      type: Boolean, default: false
  field :timetolive, type: Integer # minutes
  PLACEMENT_OPTIONS = [:any, :ground, :underground, :onground]
  has_many :rooms
  has_many :items

  mount_uploader :icon, SwfUploader, mount_on: :icon_filename
  validates_presence_of :name
  validates_presence_of :placement

  def ref_items
    self.items.refs.map(&:id)
  end

  def ref_rooms
    self.rooms.refs.map(&:id)
  end
end
