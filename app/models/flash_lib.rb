class FlashLib
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active,  type: Boolean
  field :desc,    type: String
  field :social,     type: String
  field :local_path, type: String

  mount_uploader :swf, SwfUploader, mount_on: :swf_filename
  before_save :check_active

  default_scope desc(:created_at)

  def self.active(social)
    self.where(active: true, social: social).first
  end

  def activate
    self.update_attribute :active, true
  end

  def check_active
    if self.active and self.class.active(self.social)
      self.class.update_all social: self.social, active: false
    end
  end

  def path(local = false)
    local ? self.local_path : self.swf_url
  end
end
