class Admin::RoomTypesController < Admin::BaseController
  respond_to :html, :json
  def index
    @use_fields = %w(name placement unique)
    super
  end
end
