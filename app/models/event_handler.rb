class EventHandler
  include Mongoid::Document

  field :event_type, type: String
  field :message_title, type: String
  field :message_body, type: String
  field :rewards, type: String, default: {}
  field :tell_friends, type: Boolean, default: false

  EVENTS = [ :levelup, :first_login, :max_coins, :atm_empty, :cashdesk_full, :unsupported_operation, :overdue_client ]

  validates_uniqueness_of :event_type
  validates_presence_of :event_type, :message_title, :message_body

  def self.trigger(user, event, options = {})
    # STUB
    case event
    when :levelup
      user.send_message({
        requestId: -1,
        response: {levelnumber: options.level.number}
      })
    end
  end
end
