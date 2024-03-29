class Atm < Item
  field :service_speed,     type: Integer, default: 10 # seconds
  field :capacity,          type: Integer, default: 100 # coins
  field :operations,        type: Array,   default: []

  field :cash,              type: Integer
  field :client_id,         type: String
  field :operation_id,      type: String

  before_create :fill_cash

  def fill_cash
    self.cash = self.capacity
  end

  def do_encashment
    raise 'not enough coins' if user.coins < self.capacity
    user.update_attribute :coins, user.coins - self.capacity
    self.update_attribute :cash, self.capacity
    self.encashment_done
  end

  state_machine initial: :standby do
    event :serve_client do
      transition :standby => :serving_client
    end

    state :serving_client do
      validates_presence_of :client_id

      def serve
        client = Client.find client_id
        client_cash = client.operations[operation_id].to_i
        self.client_id = nil
        self.operation_id = nil
        self.cash -= client_cash
        self.save
        if self.cash > 0
          self.client_served
          user.update_attribute :reputation, user.reputation + client.reputation
        else
          self.capacity_reached
        end
        self.cash > 0 ? self.client_served : self.capacity_reached
      end

      handle_asynchronously :serve, run_at: Proc.new { |i|
        i.time_per_client.seconds.from_now
      }
    end

    after_transition :to => :serving_client do |i|
      i.serve
    end

    after_transition :to => :empty do |i|
      i.user.send_message({
        requestId: -4, # item expired
        response: { id: i.id, message: 'ATM empty' }
      })
    end

    event :client_served do
      transition :serving_client => :standby
    end

    event :capacity_reached do
      transition :serving_client => :empty
    end

    event :encashment_done do
      transition :empty => :standby
    end

    after_transition :to => :empty do |i|
      EventHandler.trigger i.user, :atm_empty, {item: i}
    end
  end

  def enough_cash
    client = Client.find client_id
    cash >= client.operations[operation_id].to_i
  end

  def time_per_client
    service_speed
  end
end
