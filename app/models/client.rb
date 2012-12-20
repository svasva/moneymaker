class Client
  include Mongoid::Document

  field :name,                 type: String
  field :desc,                 type: String
  field :cash,                 type: Integer
  field :operations,           type: Hash, default: {} # operationType => cash
  field :requirements,         type: Hash, default: {}
  field :wait_time,            type: Integer # seconds
  field :weight,               type: Float
  field :weight_rep_mod,       type: Float
  field :weight_cred_mod,      type: Float
  field :weight_debt_mod,      type: Float
  field :weight_cred_perc_mod, type: Float
  field :weight_debt_perc_mod, type: Float

  validates_presence_of :name, :desc, :wait_time, :weight

  mount_uploader :swf,  SwfUploader
  mount_uploader :icon, SwfUploader
end
