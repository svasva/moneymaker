class Quest
  include Mongoid::Document

  belongs_to :parent, class_name: 'Quest', index: true
  has_many :children, class_name: 'Quest', foreign_key: 'parent_id'

  field :name,          type: String
  field :desc,          type: String
  field :complete_text, type: String

  field :requirements,  type: Hash, default: {items: {}, rooms: {}}
  field :complete_requirements, type: Hash, default: {items: {}, rooms: {}}
  field :rewards,       type: Hash, default: {items: {}}

  mount_uploader :icon, SwfUploader

  validates_presence_of :name, :desc, :complete_text
end
