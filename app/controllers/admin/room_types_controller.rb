class Admin::RoomTypesController < InheritedResources::Base
  respond_to :html, :json
  def index
    @use_fields = %w(name placement unique)
    super
  end
end
