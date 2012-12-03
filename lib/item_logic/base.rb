module ItemLogic::Base
  extend ActiveSupport::Concern
  included do
    state_machine initial: :standby do
      state :standby
      state :collecting
    end
  end
end
