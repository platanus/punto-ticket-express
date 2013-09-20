class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name, :producer_id
  attr_accessible :ticket_types_attributes, :is_published, :start_time, :end_time, :data_to_collect
  attr_accessible :logo

  # paperclip
  has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  # Saves required fields with the following format
  #  [{:name => :attr1, :required => false}, {:name => :attr2, :required => true}]
  # Possible attribute values are defined on NestedResource::NESTABLE_ATTRIBUTES constant
  serialize :data_to_collect, Array

  validates_presence_of :address, :description, :name, :organizer_name
  validate :remains_published?

  before_destroy :can_destroy?

  belongs_to :user
  belongs_to :producer
  has_many :ticket_types, dependent: :destroy
  has_many :tickets, through: :ticket_types
  has_many :users, through: :tickets

  accepts_nested_attributes_for :ticket_types, allow_destroy: true

  scope :published, where(is_published: true)

  def data_to_collect=(val)
    # create data collection and remove nil data
    val = val.select.with_index{|data, i| !data[i.to_s].nil?}
    val = val.reduce([]) do |data, i|
      data << {:name => i[:name].to_s, :required => !i.has_value?('optional')}
    end

    # overwrite the attribute writer
    write_attribute(:data_to_collect, val)
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
end
