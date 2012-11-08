class Greeting
  include Mongoid::Document
  field :text,    type: String
  field :weight,  type: Integer
end
