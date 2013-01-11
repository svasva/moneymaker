class Atm < Item
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
      validate :enough_cash

      def serve
        client = Client.find client_id
        client_cash = client.operations[current_operation].to_i
        self.update_attributes({
          client_id: nil,
          operation_id: nil,
          cash: self.cash - client_cash)}
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
  end

  def enough_cash
    client = Client.find client_id
    client.operations[current_operation].to_i <= cash
  end

  def time_per_client
    service_speed
  end
end
