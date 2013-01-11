class FlashLib < Swfclient
  field :social,     type: String
  field :local_path, type: String

  default_scope type(FlashLib)

  def path(local = false)
    local ? self.local_path : self.swf_url
  end
end
