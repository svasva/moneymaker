class Swfclient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active,  type: Boolean
  field :desc,    type: String

  mount_uploader :swf, SwfUploader

  def self.active
    self.where(active: true).first
  end

  def activate
    Swfclient.active.update_attribute active: false
    self.update_attribute active: true
  end
end
