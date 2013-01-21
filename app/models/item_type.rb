class ItemType
  include Mongoid::Document
  field :name,       type: String
  field :placement,  type: String
  field :unique,     type: Boolean, default: false
  field :timed,      type: Boolean, default: false
  field :timetolive, type: Integer # minutes
  PLACEMENT_OPTIONS = [:any, :wall, :none]
  has_many :items

  mount_uploader :icon, SwfUploader, mount_on: :icon_filename
  validates_presence_of :name
  validates_presence_of :placement
end
