# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :social,           type: String
  field :social_id,        type: String
  field :name,             type: String
  field :male,             type: Boolean
  field :age,              type: Integer
  field :last_sign_in,     type: DateTime
  field :friend_visits,    type: Integer, default: 0

  field :bank_name,        type: String,  default: 'Мой банк'
  field :experience,       type: Integer, default: 0
  field :reputation,       type: Integer, default: 0
  field :reputation_bonus, type: Integer, default: 0
  field :max_coins,        type: Integer, default: ->{Setting.get.bank_capacity}
  field :coins,            type: Integer, default: ->{Setting.get.start_coins}
  field :coins_spent,      type: Integer, default: 0
  field :money,            type: Integer, default: ->{Setting.get.start_money}
  field :money_spent,      type: Integer, default: 0
  field :money_bought,     type: Integer, default: 0
  field :credits,          type: Integer, default: 0
  field :credit_percent,   type: Integer, default: 10
  field :deposits,         type: Integer, default: 0
  field :deposit_percent,  type: Integer, default: 10
  field :client_interval,  type: Integer, default: 10
  field :crime_interval,   type: Integer, default: 10
  field :online,           type: Boolean, default: false
  field :pushing_clients,  type: Boolean, default: false

  field :accepted_quests,  type: Array, default: []
  field :completed_quests, type: Array, default: []

  scope :online, where(online: true)

  index({social: 1, social_id: 1}, {unique: true})
  index({online: 1})
  validates_uniqueness_of [:social, :social_id]

  has_many :user_sockets, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :branches, dependent: :destroy

  has_and_belongs_to_many :friends, class_name: 'User'
  after_update :update_client, :calc_stats, :fire_events
  after_create :setup_start_location, :first_login

  def capacity
    max_coins
  end

  def first_login
    EventHandler.trigger self, :first_login
  end

  def nextlevel
    level.next.experience
  end

  def min_rep
    level.min_reputation
  end

  def calc_stats
    fields = self.attributes.select { |k,v| changes.has_key? k }
    # TODO: add UserStats model with transaction details
  end

  def fire_events
    # level up event
    if changes.has_key? 'experience'
      from, to = changes['experience']
      if level.next and (from..to).include? level.next.experience
        EventHandler.trigger(self, :levelup, {level: level.next})
      end
    end
    if changes.has_key? 'coins'
      if self.coins >= self.max_coins
        EventHandler.trigger self, :max_coins
      end
    end
  end

  def update_client
    send_message({
      requestId: -1,
      response: self.attributes.select {|k,v| changes.has_key? k}
    })
  end

  def setup_start_location
    # TODO: fixme
    Room.refs.where(startup: true).each do |room|
      user_room = room.add_to_user self.id, room.startup_x, room.startup_y
      Item.refs.where(startup: true, startup_room_id: room.id).each do |item|
        user_item = item.add_to_user(
          self.id,
          item.startup_x,
          item.startup_y,
          item.startup_rot)
        user_item.update_attribute :room_id, user_room.id
      end
    end
  end

  # all non-completed & non-accepted quests where parent quest is completed
  # or there is no parent quest
  def available_quests
    ret = Quest.nin(_id: self.completed_quests + self.accepted_quests)
    ret.any_of({:parent_id.in => self.completed_quests}, {parent_id: nil})
  end

  def level
    BankLevel.where(:experience.lte => self.experience).last
  end

  def levelnumber
    level.number
  end

  def send_message(message)
    return true unless online
    HTTParty.post "#{SOCKET_API}/#{self.id}", {body: message}
  end

  def requirements_met?(requirements)
    return true unless requirements
    return true if requirements.empty?
    requirements.each do |type, req|
      next if req == 0 or req == '' or !req
      case type
      when 'items'
        req.each do |item_id, count|
          own_count = self.items.where(reference_id: item_id).count
          raise 'not enough required items: ' + item_id if own_count < count.to_i
        end
      when 'level'
        if self.level and req.to_i > self.level.number
          raise "level requirement not met: #{req} > #{self.level.number}"
        end
      when 'reputation'
        if self.reputation and req.to_i > self.reputation
          raise "reputation requirement not met: #{req} > #{self.reputation}"
        end
      when 'friends'
        if self.friends and req.to_i > self.friends.count
          raise "friends requirement not met: #{req} > #{self.friends.count}"
        end
      end
    end
    return true
  end

  def give_rewards(rewards)
    return false unless rewards
    return false if rewards.empty?
    rewards.each do |type, rew|
      case type
      when 'items'
        req.each do |item_id, count|
          item = Item.find(item_id)
          # TODO: error logging
          if item and requirements_met? item.requirements
            count.to_i.times { item.add_to_user self.id }
          end
        end
      when 'experience'
        self.inc :experience, rew.to_i
      when 'reputation'
        self.inc :reputation, rew.to_i
      # TODO: log financial stats
      when 'coins'
        self.inc :coins, rew.to_i
      when 'money'
        self.inc :money, rew.to_i
      end
    end
  end

  def buy_content(content, currency)
    raise 'wrong currency' unless [:coins, :money].include? currency
    raise 'requirements not met' unless requirements_met? content.requirements
    content_cost = content[currency.to_s + '_cost']
    raise 'no price is set for currency' unless content_cost
    raise 'currency requirement not met' if content_cost > self[currency]
    usercontent = content.add_to_user self.id
    self[currency] -= content_cost
    self.give_rewards content.rewards
    self.save
    return usercontent
  end

  def start_game
    send_client
    unless self.reload.pushing_clients
      generate_clients
      self.update_attribute :pushing_clients, true
    end
  end

  def effects
    items.on_stage.map(&:effects).reduce({}) do |mem, item|
      item.each do |k,v|
        mem.has_key?(k) ? mem[k] += v.to_i : mem[k] = v.to_i
      end
      mem
    end
  end

  def generate_clients
    unless self.reload.online
      self.update_attribute :pushing_clients, false
      return true
    end
    send_client
    generate_clients
  end

  def send_client
    client = Client.get_random
    supported = self.supported_operations
    client.operations.keys.each do |op|
      unless supported.include? op
        EventHandler.trigger self, :unsupported_operation, {client: client, operation: op}
      end
    end
    send_message({
      requestId: -3,
      response: client.as_json(methods: [:operations_mapped, :swf_url])
    })
  end

  def supported_operations
    itms = items.in(_type: ['Atm', 'CashDesk']).map(&:operations).flatten.uniq
    itms.delete ''
    itms
  end

  handle_asynchronously :generate_clients, run_at: Proc.new { |i|
    Setting.get.time_per_client.seconds.from_now
  }
end
