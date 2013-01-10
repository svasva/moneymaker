class Admin::QuestsController < InheritedResources::Base
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name desc)
    true
  end
end
