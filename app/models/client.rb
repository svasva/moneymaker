class Client
  include Mongoid::Document

  field :name,                 type: String
  field :desc,                 type: String
  field :operations,           type: Hash, default: {} # operation_id => cash
  field :requirements,         type: Hash, default: {}
  field :wait_time,            type: Integer # seconds
  field :weight,               type: Float
  field :weight_rep_mod,       type: Float
  field :weight_cred_mod,      type: Float
  field :weight_debt_mod,      type: Float
  field :weight_cred_perc_mod, type: Float
  field :weight_debt_perc_mod, type: Float

  has_many :bank_operations

  validates_presence_of :name, :desc, :wait_time, :weight

  mount_uploader :swf,  SwfUploader, mount_on: :swf_filename
  mount_uploader :icon, SwfUploader, mount_on: :icon_filename

  def operations_mapped
    operations.map {|k,v| { id: k, cash: v } }
  end

  def self.get_random
    hash = {}
    self.all.each {|g|
      hash[g.weight] ||= []
      hash[g.weight] << g
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
