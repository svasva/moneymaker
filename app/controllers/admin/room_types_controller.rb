class Admin::RoomTypesController < Admin::BaseController
  respond_to :html, :json
  def index
    @use_fields = %w(order name placement unique)
    super
  end
end
