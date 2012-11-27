class ItemType
  include Mongoid::Document
  field :name,       type: String
  field :placement,  type: String
  field :unique,     type: Boolean
  field :timed,      type: Boolean
  field :timetolive, type: Integer # minutes
  PLACEMENT_OPTIONS = %w(any wall none)
  has_many :items

  default_scope where(_type: nil)

  def self.placement_options
    namespace = self.name.downcase
    PLACEMENT_OPTIONS.map do |opt|
      [I18n.t(namespace + '.placement_options.'+opt), opt]
    end
  end
end
