class Branch < GameContent
  include Mongoid::Document
  field :income_modifier,     type: Float
  field :crime_probability,   type: Integer
  field :encashment_speed,    type: Integer
  field :level,               type: Integer

  belongs_to :upgrade, class_name: 'Branch', foreign_key: 'upgrade_id'
end
