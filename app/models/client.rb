class Client
  include Mongoid::Document

  field :name,      type: String
  field :desc,      type: String
  field :cash, type: Integer

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader
end
