class EventHandler
  include Mongoid::Document

  field :event_type, type: String
  field :message_title, type: String
  field :message_body, type: String

  EVENTS = %w(levelup)

  def self.trigger(user, event)
    binding.pry
    # STUB
  end
end
