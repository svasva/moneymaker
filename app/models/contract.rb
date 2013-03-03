class Contract
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :order,           type: Integer
  field :reference_id,    type: String

  field :name,            type: String
  field :desc,            type: String
  field :coins_cost,      type: Integer
  field :money_cost,      type: Integer
  field :sell_cost,       type: Integer
  field :requirements,    type: Hash,    default: {items: {}, rooms: {}}
  field :rewards,         type: Hash,    default: {}
  field :execution_time,  type: Integer # hours
  field :is_advert,       type: Boolean

  validates_presence_of :name, :execution_time

  mount_uploader :icon, SwfUploader, mount_on: :icon_filename

  scope :refs, where(user_id: nil)
  before_destroy :destroy_refs

  def destroy_refs
    self.references.destroy
  end

  def reference
    self.class.where(id: self.reference_id).first
  end

  # items based on this one
  def references
    self.class.where reference_id: self.id
  end

  def sell
    return false unless self.user_id
    if self.sell_cost and self.sell_cost > 0
      self.user.inc :coins, self.sell_cost
    end
    self.destroy
  end

  def start_for(user)
    raise 'already running' if user.running_contracts.map(&:id).include? self.id
    user.requirements_met? self.requirements
    user.running_contracts << { id: self.id, ending_at: end_time }
    user.save
    self.process_for(user)
  end

  def end_time
    self.execution_time.hours.from_now
  end

  def process_for(user)
    running_contracts = user.running_contracts.map &:id
    raise 'contract was not running' unless running_contracts.include? self.id
    user.running_contracts.delete_if {|rc| rc['id'] == self.id or rc[:id] == self.id}
    user.give_rewards self.rewards
    user.save
  end

  handle_asynchronously :process_for, run_at: Proc.new { |i| i.end_time }
end
