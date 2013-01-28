class Branch < GameContent
  include Mongoid::Document

  field :income_modifier,   type: Float
  field :crime_probability, type: Integer
  field :encashment_speed,  type: Integer
  field :maxlevel,          type: Integer
  belongs_to :max_level, class_name: 'BranchLevel'

  validates_presence_of :x, :y
end
