class Swfclient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active,  type: Boolean
  field :desc,    type: String

  mount_uploader :swf, SwfUploader
  before_save :check_active

  def self.active
    self.where(active: true).first or Swfclient.new
  end

  def activate
    Swfclient.active.update_attribute active: false
    self.update_attribute active: true
  end

  def check_active
    Swfclient.active.update_attribute(:active, false) if self.active
  end
end
