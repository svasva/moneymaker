class CashDesk < Item
  field :service_speed,     type: Integer, default: 10 # seconds
  field :capacity,          type: Integer, default: 100 # coins
  field :operations,        type: Array,   default: []

  field :cash,              type: Integer, default: 0 # current
  field :client_id,         type: String
  field :current_operation, type: String

  state_machine initial: :standby do
    event :serve_client do
      transition :standby => :serving_client
    end

    state :serving_client do
      validates_presence_of :client_id

      def serve
        client = Client.find client_id
        client_cash = client.operations[current_operation].to_i
        if (client_cash + cash) > capacity
          self.cash = capacity
        else
          self.cash += client_cash
        end
        self.client_id = nil
        self.operation_id = nil
        self.save
        not_full ? self.client_served : self.capacity_reached
      end

      handle_asynchronously :serve, run_at: Proc.new { |i|
        i.time_per_client.seconds.from_now
      }
    end

    after_transition :to => :serving_client do |i|
      i.serve
    end

    after_transition :to => :full do |i|
      i.user.send_message({
        requestId: -4, # item expired
        response: { id: i.id, message: 'ATM empty' }
      })
    end

    event :client_served do
      transition :serving_client => :standby
    end

    event :capacity_reached do
      transition :serving_client => :full
    end

    after_transition :to => :full do |i|
      EventHandler.trigger i.user, :cashdesk_full, {item: i}
    end
  end

  def not_full
    cash < capacity
  end

  def time_per_client
    service_speed
  end
end
