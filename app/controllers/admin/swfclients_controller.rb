class Admin::SwfclientsController < InheritedResources::Base
  respond_to :html, :json

  def activate
    resource.activate
    redirect_to collection_url
  end
end
