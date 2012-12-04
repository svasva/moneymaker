class ItemType
  include Mongoid::Document
  field :include_modules, type: Array, default: []
  field :klass_name, type: String
  field :name,       type: String
  field :placement,  type: String
  field :unique,     type: Boolean, default: false
  field :timed,      type: Boolean, default: false
  field :timetolive, type: Integer # minutes
  PLACEMENT_OPTIONS = %w(any wall none)
  has_many :items

  mount_uploader :icon, SwfUploader
  validates_presence_of :klass_name
  validates_presence_of :name
  validates_presence_of :placement
  validates_format_of :klass_name, with: /\A[aA-zZ]+[0-9]*\Z/

  default_scope where(_type: nil)

  def self.placement_options
    namespace = self.name.downcase
    PLACEMENT_OPTIONS.map do |opt|
      [I18n.t(namespace + '.placement_options.'+opt), opt]
    end
  end

  def instantinate
    return false unless klass_name
    return false if klass_name.empty?
    klass = Class.new UserItem
    include_modules.each do |m|
      klass.class_eval { include "#{m}".constantize }
    end
    Object.const_set (self.klass_name + 'Item').camelize, klass
  end

  def self.init_all
    classes = []
    self.all.each { |it| classes << it.instantinate }
    classes
  end
end
