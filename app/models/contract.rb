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
  field :execution_time,  type: Integer
  field :is_advert,       type: Boolean

  validates_presence_of :name, :execution_time

  mount_uploader :icon, SwfUploader, mount_on: :icon_filename

  before_destroy :destroy_refs

  state_machine initial: :standby do
    event :start_contract do
      transition :standby => :working
    end

    state :working do
      def run
        self.user.give_rewards self.rewards
        self.finish
      end

      handle_asynchronously :run, run_at: Proc.new { |i|
        i.execution_time.hours.from_now
      }
    end

    after_transition :to => :working do |i|
      i.run
    end

    event :finish do
      transition :working => :done
    end

    after_transition :to => :done do |i|
      i.user.send_message({
        requestId: -5, # item expired
        response: { id: i.id, message: 'contract done' }
      })
    end
  end

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
end
