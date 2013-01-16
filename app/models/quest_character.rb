class QuestCharacter
  include Mongoid::Document

  field :name, type: String
  mount_uploader :swf, SwfUploader, as: :swf_filename

  validates_presence_of :name
end
