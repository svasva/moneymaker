class Swfclient
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active,  type: Boolean
  field :desc,    type: String

  mount_uploader :swf, SwfUploader
  before_save :check_active

  default_scope where(_type: nil).desc(:created_at)

  def self.active
    self.where(active: true).first
  end

  def activate
    self.update_attribute :active, true
  end

  def check_active
    if self.active and self.class.active
      self.class.active.update_attribute(:active, false)
    end
  end
end
