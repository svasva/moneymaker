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

  def update_client
    message = {
      requestId: -1, # user update
      response: self.changes
    }.to_json
    send_message message
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
    user_sockets.each do |sock|
      HTTParty.post "#{SOCKET_API}/#{sock.id}", {body: message}
    end
  end

  def requirements_met?(requirements)
    return true unless requirements
    return true if requirements.empty?
    requirements.each do |type, req|
      next if req == 0 or req == ''
      case type
      when 'items'
        req.each do |item_id, count|
          own_count = self.items.where(reference_id: item_id).count
          return false if own_count < count
        end
      when 'level'
        return false if req.to_i > self.level
      when 'reputation'
        return false if req.to_i > self.reputation
      when 'friends'
        return false if req.to_i > self.friends.count
      end
      logger.info req.inspect
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
    return false unless [:coins, :money].include? currency
    return false unless requirements_met? content.requirements
    content_cost = content[currency.to_s + '_cost']
    return false if content_cost > self[currency]
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

  handle_asynchronously :send_message
end
