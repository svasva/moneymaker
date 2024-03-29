class Swfclient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active,  type: Boolean
  field :desc,    type: String

  mount_uploader :swf, SwfUploader, mount_on: :swf_filename
  before_save :check_active

  default_scope desc(:created_at)

  def self.active
    self.where(active: true).first
  end

  def activate
    self.update_attribute :active, true
  end

  def check_active
    if self.active and self.class.active
      self.class.update_all active: false
    end
  end
end
