class BranchLevel
  include Mongoid::Document

  field :name,       type: Integer, default: ->{self.class.count + 1}
  field :cost,         type: Integer
  field :capacity,     type: Integer
  field :profit,       type: Integer
  field :requirements, type: Hash, default: {items: {}, rooms: {}}
  field :rewards,      type: Hash, default: {}

  validates_presence_of :name, :profit, :cost, :capacity

  default_scope asc(:name)

  def next
    self.class.where(name: self.name + 1).first
  end
end
