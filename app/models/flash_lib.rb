class FlashLib < Swfclient
  field :social,     type: String
  field :local_path, type: String

  def path(local = false)
    local ? self.swf_url : self.local_path
  end
end
