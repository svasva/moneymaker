class Admin::SettingsController < InheritedResources::Base
  def index
    redirect_to [:edit, :admin, Setting.get], flash: flash
  end

  def show
    redirect_to [:edit, :admin, Setting.get], flash: flash
  end
end
