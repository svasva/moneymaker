class Branch < GameContent
  include Mongoid::Document

  belongs_to :upgrade, class_name: 'Branch', foreign_key: 'upgrade_id'
end
