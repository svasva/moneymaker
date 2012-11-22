class FlashLib < Swfclient
  field :social,     type: String
  field :local_path, type: String

  def path(local = false)
    local ? self.local_path : self.swf_url
  end
end
