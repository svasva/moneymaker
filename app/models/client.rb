class Client
  include Mongoid::Document

  field :name,         type: String
  field :desc,         type: String
  field :cash,         type: Integer
  field :operations,   type: Array, default: []
  field :requirements, type: Hash, default: {}
  field :wait_time,    type: Integer # seconds

  validates_presence_of :name, :desc, :cash

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader
end
