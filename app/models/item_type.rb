class ItemType
  include Mongoid::Document
  field :name,       type: String
  field :placement,  type: String
  field :unique,     type: Boolean, default: false
  field :timed,      type: Boolean, default: false
  field :timetolive, type: Integer # minutes
  PLACEMENT_OPTIONS = %w(any wall none)
  MODULES_OPTIONS = %w(base)
  has_many :items

  mount_uploader :icon, SwfUploader, mount_on: :icon_filename
  validates_presence_of :name
  validates_presence_of :placement

  default_scope where(_type: nil)

  def self.placement_options
    namespace = self.name.downcase
    PLACEMENT_OPTIONS.map do |opt|
      [I18n.t(namespace + '.placement_options.'+opt), opt]
    end
  end
end
