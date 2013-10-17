class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :producer_id
  attr_accessible :ticket_types_attributes, :is_published, :start_time, :end_time, :data_to_collect
  attr_accessible :logo, :theme

  # paperclip
  has_attached_file :logo, :styles => { :medium => "160x160>", :thumb => "100x100>" }

  # Saves required fields with the following format
  #  [{:name => :attr1, :required => false}, {:name => :attr2, :required => true}]
  # Possible attribute values are defined on NestedResource::NESTABLE_ATTRIBUTES constant
  serialize :data_to_collect, Array

  validates_presence_of :address, :description, :name
  validate :remains_published?
  validate :is_theme_type_valid?
  validates_attachment_content_type :logo, :content_type => /image/

  before_destroy :can_destroy?

  belongs_to :user
  belongs_to :producer
  has_many :ticket_types, dependent: :destroy
  has_many :tickets, through: :ticket_types
  has_many :users, through: :tickets
  has_many :transactions, through: :tickets, uniq: true

  accepts_nested_attributes_for :ticket_types, allow_destroy: true

  scope :published, where(is_published: true)

  delegate :name, to: :producer, prefix: true, allow_nil: true
  delegate :description, to: :producer, prefix: true, allow_nil: true

  after_initialize :default_theme

  def data_to_collect=(val)
    result = []

    val.each_with_index do |data, index|
      attr = data["name"]
      value = data[index.to_s].to_sym
      next if value == :none
      result << {:name => attr, :required => (value == :required)}
    end

    # overwrite the attribute writer
    write_attribute(:data_to_collect, result)
  end

  def nested_attributes
    return [] unless self.data_to_collect
    attributes = []
    NestedResource.nested_attributes.each do |col|
      self.data_to_collect.each do |attr|
        if col[:attr].to_s == attr[:name]
          attributes << col.merge({required: attr[:required]})
        end
      end
    end
    attributes
  end

  def required_nested_attributes
    required_values = self.nested_attributes.reject{ |attr| !attr[:required] }
    required_values.map {|item| item[:attr] }
  end

  def optional_nested_attributes
    optional_values = self.nested_attributes.reject{ |attr| attr[:required] }
    optional_values.map {|item| item[:attr] }
  end

  private
    def remains_published?
      if !self.new_record? and self.is_published_was and
        (self.is_published_was != self.is_published)
        errors.add(:is_published, :published_event_cant_be_unpublished)
        return false
      end
    end

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end
    end

    def default_theme
      self.theme ||= PTE::Theme::default
    end

    def is_theme_type_valid?
      unless PTE::Theme::is_valid? self.theme
        self.errors.add(:theme, :invalid_theme_type)
        return false
      end
    end

end
