class QuestCharacter
  include Mongoid::Document

  field :name, type: String
  mount_uploader :swf, SwfUploader, as: :swf_filename
  mount_uploader :icon, SwfUploader, as: :icon_filename

  validates_presence_of :name
end
