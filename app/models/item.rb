class Item < GameContent
  embeds_many :contracts
  belongs_to :room_type
  belongs_to :item_type
  belongs_to :room

  field :startup_room_id, type: String

  validates_presence_of :item_type_id
  validates_length_of :desc, maximum: 150

  REQUIREMENT_OPTIONS = %w(items level reputation)
  EFFECT_MAXCOUNT = 3
  EFFECT_OPTIONS = [
    'reputation',
    'income',
    'service_speed',
    'queue_time',
    'max_coins',
    'encashment_speed',
    'encashment_speed_atm',
    'security',
    'security_branch',
    'atm_crash'
  ]

  def self.effect_options
    namespace = self.name.downcase
    EFFECT_OPTIONS.map do |opt|
      [I18n.t(namespace + '.effect_options.' + opt), opt]
    end
  end
end
