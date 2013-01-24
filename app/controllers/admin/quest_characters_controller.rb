class Admin::QuestCharactersController < Admin::BaseController
  before_filter :set_fields

  def set_fields
    @use_fields = %w(name)
    true
  end
end
