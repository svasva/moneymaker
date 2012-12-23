class Client
  include Mongoid::Document

  field :name,                 type: String
  field :desc,                 type: String
  field :cash,                 type: Integer
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

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader

  def operations_mapped
    operations.map {|k,v| { 'id' => k, 'cash' => v } }
  end
end
