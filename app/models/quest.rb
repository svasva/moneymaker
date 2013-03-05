class Quest
  include Mongoid::Document

  belongs_to :parent, class_name: 'Quest', index: true
  has_many :children, class_name: 'Quest', foreign_key: 'parent_id'
  belongs_to :quest_character

  field :name,          type: String
  field :desc,          type: String
  field :complete_text, type: String

  field :requirements,  type: Hash, default: {items: {}, rooms: {}}
  field :complete_requirements, type: Hash, default: {items: {}, rooms: {}}
  field :rewards,       type: Hash, default: {items: {}}

  mount_uploader :icon, SwfUploader, as: :icon_filename

  validates_presence_of :name, :desc, :complete_text, :quest_character_id

  def complete_for(user)
    raise 'quest is not accepted' unless user.accepted_quests.include? self.id
    user.requirements_met? self.complete_requirements
    user.completed_quests << self.id
    user.accepted_quests.delete self.id
    user.give_rewards self.rewards
    user.save
  end

  def accept_for(user)
    user.requirements_met? self.requirements
    user.accepted_quests << self.id
    user.save
  end

  def character_swf
    self.quest_character.swf_url
  end

  def character_icon
    self.quest_character.icon_url
  end
end
