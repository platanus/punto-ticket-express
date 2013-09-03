class Event < ActiveRecord::Base
  # attrs
  attr_accessible :user_id, :address, :custom_url, :description, :name, :organizer_description, :organizer_name, :producer_id
  attr_accessible :ticket_types_attributes, :is_published, :start_time, :end_time, :data_to_collect

  # serialize
  serialize :data_to_collect, Array

  # validations
  validates_presence_of :address, :description, :name, :organizer_name, :producer_id
  validate :remains_published?

  # callbacks
  before_destroy :can_destroy?

  # relationship
  belongs_to :user
  belongs_to :producer
  has_many :ticket_types, dependent: :destroy
  has_many :tickets, through: :ticket_types
  has_many :users, through: :tickets

  accepts_nested_attributes_for :ticket_types

  scope :published, -> { where is_published: true }

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
