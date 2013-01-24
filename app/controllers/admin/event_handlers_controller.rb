class Admin::EventHandlersController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(event_type message_title)
    true
  end

end
