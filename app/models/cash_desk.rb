class CashDesk < Item
  field :service_speed,  type: Integer, default: 10 # seconds
  field :capacity,       type: Integer, default: 100 # coins
  field :accept_clients, type: Array,   default: []
  field :services,       type: Array,   default: []

  field :cash,           type: Integer, default: 0 # current
  field :client_id,      type: String

  SERVICE_OPTIONS = %w(credit debit)

  state_machine initial: :standby do
    event :serve_client do
      transition :standby => :serving_client
    end

    state :serving_client do
      validates_presence_of :client_id
      validate :not_full

      def serve
        client = Client.find client_id
        if client.cash > (capacity - cash)
          self.update_attribute :cash, capacity
        else
          self.inc :cash, client.cash
        end
        not_full ? self.client_served : self.capacity_reached
        self.update_attribute :client_id, nil
      end

      handle_asynchronously :serve, run_at: Proc.new { |i|
        i.time_per_client.seconds.from_now
      }
    end

    after_transition :to => :serving_client do |i|
      i.serve
    end

    event :client_served do
      transition :serving_client => :standby
    end

    event :capacity_reached do
      transition :serving_client => :full
    end
  end

  def not_full
    cash < capacity
  end

  def time_per_client
    service_speed
  end
end
