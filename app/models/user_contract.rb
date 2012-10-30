class UserContract
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :contract
  belongs_to :user_item
  embedded_in :user
end
