class Admin::BaseController < InheritedResources::Base
  before_filter :authenticate_admin!

  def show
    redirect_to collection_url
  end
end
