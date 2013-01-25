class Branch < GameContent
  include Mongoid::Document

  field :income_modifier,   type: Float
  field :crime_probability, type: Integer
  field :encashment_speed,  type: Integer
  field :maxlevel,          type: Integer
end
