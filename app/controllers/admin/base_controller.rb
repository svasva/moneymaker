class Admin::BaseController < InheritedResources::Base
  before_filter :authenticate_admin!
  before_filter :set_rnames

  def show
    redirect_to collection_url
  end

  def set_rnames
    @rpname = resource_class.name.pluralize.underscore
    @rname = resource_class.name.underscore
  end
end
