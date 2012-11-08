class Greeting
  include Mongoid::Document
  field :text,    type: String
  field :weight,  type: Integer, default: 1

  # get random greeting based on their weights
  def self.get_random
    hash = {}
    Greeting.all.each {|g|
      hash[g.weight] ||= []
      hash[g.weight] << g.text
    }
    total_weight = hash.inject(0) { |sum,(weight,v)| sum+weight }
    running_weight = 0
    n = rand*total_weight
    hash.each do |weight,v|
      return v.sample if n > running_weight && n <= running_weight+weight
      running_weight += weight
    end
  end
end
