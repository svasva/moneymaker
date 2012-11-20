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

  embeds_many :user_rooms
  embeds_many :user_items
  embeds_many :user_contracts
  has_many :user_sockets, dependent: :destroy
  has_and_belongs_to_many :friends, class_name: 'User'
  after_update :update_client
  after_save :setup_start_location

  def update_client
    message = {
      requestId: -1, # user update
      response: self.changes
    }.to_json
    send_message message
  end

  def setup_start_location
    self.user_rooms.destroy_all
    self.user_contracts.destroy_all
    Room.where(startup: true).each do |room|
      UserRoom.create(room: room, user: self)
    end
    Item.where(startup: true).each do |item|
      UserItem.create(
        user: self,
        item: item,
        room_id: self.user_rooms.first.id,
        x: item.startup_x,
        y: item.startup_y
      )
    end
  end

  def send_message(message)
    user_sockets.each do |sock|
      HTTParty.post("#{SOCKET_API}/#{sock.id}", {body: message})
    end
  end

  def requirements_met?(requirements)
    return true unless requirements
    return true if requirements.empty?
    requirements.each do |type, req|
      case type
      when 'items'
        req.each do |item_id, count|
          own_count = self.user_items.where(item_id: item_id).count
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
            count.times { UserItem.create(user: self, item: item) }
          end
        end
      when 'experience'
        self.inc :experience, rew
      when 'reputation'
        self.inc :reputation, rew
      when 'reputation_bonus'
        self.inc :reputation_bonus, rew
      # TODO: log financial stats
      when 'coins'
        self.inc :coins, rew
      when 'money'
        self.inc :money, rew
      end
    end
  end

  def buy_item(item, currency)
    return false unless requirements_met? item.requirements
    item_cost = item[currency.to_s + '_cost']
    return false if item_cost > self[currency]
    UserItem.create(item: item, user: self)
    self[currency] -= item_cost
    self.give_rewards item.rewards
    self.save
    return true
  end

  if Rails.env.production?
    handle_asynchronously :send_message
  end
end
