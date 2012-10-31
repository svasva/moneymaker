# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :social,            type: String
  field :social_id,         type: String
  field :name,              type: String
  field :male,              type: Boolean
  field :age,               type: Integer
  field :last_sign_in,      type: DateTime
  field :friend_visits,     type: Integer, default: 0

  field :bank_name,         type: String,  default: 'Мой банк'
  field :experience,        type: Integer, default: 0
  field :level,             type: Integer, default: 1
  field :reputation,        type: Integer, default: 0
  field :reputation_bonus,  type: Integer, default: 0
  field :coins,             type: Integer, default: 0
  field :coins_max,         type: Integer, default: 100
  field :coins_spent,       type: Integer, default: 0
  field :money,             type: Integer, default: 0
  field :money_spent,       type: Integer, default: 0
  field :money_bought,      type: Integer, default: 0
  field :credits,           type: Integer, default: 0
  field :credit_percent,    type: Integer, default: 10
  field :deposits,          type: Integer, default: 0
  field :deposit_percent,   type: Integer, default: 10
  field :client_interval,   type: Integer, default: 10
  field :crime_interval,    type: Integer, default: 10

  index({social: 1, social_id: 1}, {unique: true})

  embeds_many :user_items
  embeds_many :user_contracts
  has_many :user_sockets
  has_and_belongs_to_many :friends, class_name: 'User'
end
