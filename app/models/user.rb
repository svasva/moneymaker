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
  field :level,            type: Integer, default: 1
  field :reputation,       type: Integer, default: 0
  field :reputation_bonus, type: Integer, default: 0
  field :coins,            type: Integer, default: 0
  field :coins_max,        type: Integer, default: 100
  field :coins_spent,      type: Integer, default: 0
  field :money,            type: Integer, default: 0
  field :money_spent,      type: Integer, default: 0
  field :money_bought,     type: Integer, default: 0
  field :credits,          type: Integer, default: 0
  field :credit_percent,   type: Integer, default: 10
  field :deposits,         type: Integer, default: 0
  field :deposit_percent,  type: Integer, default: 10
  field :client_interval,  type: Integer, default: 10
  field :crime_interval,   type: Integer, default: 10

  index({social: 1, social_id: 1}, {unique: true})

  has_many :user_sockets, dependent: :destroy
  has_and_belongs_to_many :friends, class_name: 'User'
  after_update :update_client
  after_create :setup_start_location
  before_destroy :destroy_refs

  def destroy_refs
    self.items.destroy
    self.rooms.destroy
  end

  def update_client
    send_message({
      requestId: -1,
      response: self.attributes.select {|k,v| changes.has_key? k}
    })
  end

  def setup_start_location
    Room.where(startup: true).each do |room|
      user_room = room.add_to_user self.id, room.startup_x, room.startup_y
      Item.where(startup: true, startup_room_id: room.id).each do |item|
        user_item = item.add_to_user self.id, item.startup_x, item.startup_y
        user_item.update_attribute :room_id, user_room.id
      end
    end
  end

  def send_message(message)
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
          raise 'not enough required items: ' + item_id if own_count < count
        end
      when 'level'
        if self.level and req.to_i > self.level
          raise "level requirement not met: #{req} > #{self.level}"
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

  def items
    GameContent.where(user_id: self.id).ne(_type: 'Room')
  end

  def rooms
    GameContent.where(user_id: self.id, _type: 'Room')
  end

  def start_game
    generate_client(true)
  end

  def accepted_services
    services = items.cash_desks.map(&:service).flatten
    services += items.atms.map(&:service).flatten
    services.uniq
  end

  def accepted_clients
    accept_clients = items.cash_desks.map(&:accept_clients).flatten
    accept_clients += items.atms.map(&:accept_clients).flatten
    accept_clients.uniq
  end

  def generate_client(first_time = false)
    client = Client.new(name: 'test1', desc: 'assd', cash: 340)
    item = items.atms.sample
    send_message({
      requestId: -3,
      response: { client: client.attributes, item_id: item.id }
    })
  end
end
