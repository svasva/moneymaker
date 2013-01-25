class BranchLevel
  include Mongoid::Document

  field :capacity,     type: Integer
  field :number,       type: Integer
  field :profit,       type: Integer
  field :cost,         type: Integer
  field :requirements, type: Hash, default: {items: {}, rooms: {}}
  field :rewards,      type: Hash, default: {}

  validates_presence_of :number, :profit, :cost, :capacity
  validates_uniqueness_of :number

  default_scope asc(:number)

  def next
    self.class.where(number: self.number + 1).first
  end
end
