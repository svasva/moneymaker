class BankLevel
  include Mongoid::Document
  field :number,          type: Integer
  field :experience,      type: Integer
  field :min_reputation,  type: Integer
  field :rewards,         type: Hash,    default: {}

  validates_presence_of :number, :experience, :min_reputation
  validates_uniqueness_of :number

  default_scope asc(:number)

  def self.for_exp(exp)
    BankLevel.where(:experience.lte => exp).last
  end

  def next
    BankLevel.where(number: self.number + 1).first
  end
end
