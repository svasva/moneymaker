class Admin::RoomTypesController < InheritedResources::Base
  def index
    @use_fields = %w(name placement unique)
    super
  end
end
