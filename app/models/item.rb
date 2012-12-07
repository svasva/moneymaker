class Item
  include Mongoid::Document

  embeds_many :contracts
  belongs_to :room_type
  belongs_to :item_type

  field :name,              type: String
  field :desc,              type: String
  field :type,              type: String
  field :money_cost,        type: Integer
  field :coins_cost,        type: Integer
  field :sell_cost,         type: Integer
  field :size_x,            type: Integer, default: 1
  field :size_y,            type: Integer, default: 1
  field :height,            type: Float,   default: 1
  field :reputation_bonus,  type: Integer
  field :startup,           type: Boolean, default: false
  field :startup_x,         type: Integer
  field :startup_y,         type: Integer
  field :startup_room_id,   type: String

  field :requirements,      type: Hash,    default: {items: {}, rooms: {}}
  field :rewards,           type: Hash,    default: {}
  field :effects,           type: Hash,    default: {}

  field :order,             type: Integer

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader

  validates_presence_of :name, :desc, :order
  validates_presence_of :size_x, :size_y, :size_y, :height
  validates_presence_of :item_type_id
  validates_length_of :desc, maximum: 150

  default_scope where(_type: nil).asc(:order)

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
