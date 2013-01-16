class EventHandler
  include Mongoid::Document

  field :event_type, type: String
  field :message_title, type: String
  field :message_body, type: String

  EVENTS = [ :levelup ]

  validates_uniqueness_of :event_type
  validates_presence_of :event_type, :message_title, :message_body

  def self.trigger(user, event, options = {})
    # STUB
  end
end
