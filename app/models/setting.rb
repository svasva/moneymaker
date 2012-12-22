class Setting
  include Mongoid::Document
  field :time_per_client,  type: Integer, default: 15
  field :start_coins, type: Integer, default: 100
  field :start_money, type: Integer, default: 10

  def self.get
    self.find_or_create_by({})
  end
end
