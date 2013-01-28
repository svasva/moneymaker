class BranchLevel
  include Mongoid::Document

  field :number,       type: Integer, default: ->{self.class.count + 1}
  field :cost,         type: Integer
  field :capacity,     type: Integer
  field :profit,       type: Integer
  field :requirements, type: Hash, default: {items: {}, rooms: {}}
  field :rewards,      type: Hash, default: {}

  validates_presence_of :number, :profit, :cost, :capacity

  default_scope asc(:number)

  def next
    self.class.where(number: self.number + 1).first
  end
end
