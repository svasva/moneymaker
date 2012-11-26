class RoomType
  include Mongoid::Document
  field :name,      type: String
  field :placement, type: String
  PLACEMENT_OPTIONS = %w(any ground underground onground)
  has_many :items
  has_many :rooms

  def self.placement_options
    PLACEMENT_OPTIONS.map do |opt|
      [I18n.t('roomtype.placement_options.'+opt), opt]
    end
  end
end
