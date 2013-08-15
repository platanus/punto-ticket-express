class Ticket < ActiveRecord::Base
  # attrs
  attr_accessible :payment_status, :quantity, :ticket_type_id, :user_id

  # relationship
  belongs_to :ticket_type
  belongs_to :user
  has_one :event, through: :ticket_type

  # validations
  validates :payment_status, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :ticket_type_id, presence: true
  validates :user_id, presence: true
  validate :is_ticket_type_valid?
  validate :is_payment_status_valid?
  validate :is_user_id_valid?
  validate :can_sell_tickets?
  validate :check_payment_status

  scope :processing, where(payment_status: PTE::PaymentStatus.processing)
  scope :completed, where(payment_status: PTE::PaymentStatus.completed)
  scope :inactives, where(payment_status: PTE::PaymentStatus.inactive)
  scope :by_type, lambda {|ticket_type_id| where(ticket_type_id: ticket_type_id)}

  delegate :quantity, to: :ticket_type, prefix: true, allow_nil: true
  delegate :available_tickets_count, to: :ticket_type, prefix: false, allow_nil: true

  def self.unavailable
    processing_tickets = processing.where_values.reduce(:and)
    completed_processing_tickets = completed.where_values.reduce(:and)
    where(processing_tickets.or(completed_processing_tickets))
  end

  def can_sell_tickets?
    return false unless self.ticket_type

    if self.new_record? and (self.quantity > self.available_tickets_count)
      self.errors.add(:ticket_type_id, :ticket_quantity_greater_than_type_quantity)
      return false

    elsif (self.payment_status == PTE::PaymentStatus.processing or
      self.payment_status == PTE::PaymentStatus.completed) and
      self.quantity > (self.available_tickets_count + self.quantity_was)
      self.errors.add(:ticket_type_id, :ticket_quantity_greater_than_type_quantity)
      return false
    end
  end

  def check_payment_status
    if self.payment_status_was != self.payment_status and
      (self.payment_status_was == PTE::PaymentStatus.inactive or 
       self.payment_status_was == PTE::PaymentStatus.completed)
      self.errors.add(:payment_status, :inactive_or_completed_cant_change)
      return false
    end
  end

  def is_user_id_valid?
    if User.find_by_id(self.user_id).nil?
      self.errors.add(:user_id, :invalid_user_given)
      return false
    end
  end

  def is_ticket_type_valid?
    if TicketType.find_by_id(self.ticket_type_id).nil?
      self.errors.add(:ticket_type_id, :invalid_ticket_type_given)
      return false
    end
  end

  def is_payment_status_valid?
    unless PTE::PaymentStatus.is_valid? self.payment_status
      self.errors.add(:payment_status, :invalid_payment_type)
      return false
    end
  end 
end
