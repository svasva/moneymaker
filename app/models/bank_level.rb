class BankLevel
  include Mongoid::Document
  field :number,          type: Integer
  field :experience,      type: Integer
  field :min_reputation,  type: Integer

  validates_presence_of :number, :experience, :min_reputation
  validates_uniqueness_of :number

  default_scope asc(:number)
end
