class RoomType < ItemType
  PLACEMENT_OPTIONS = %w(any ground underground onground)
  has_many :rooms
  def self.placement_options
    namespace = self.name.downcase
    PLACEMENT_OPTIONS.map do |opt|
      [I18n.t(namespace + '.placement_options.'+opt), opt]
    end
  end
end
