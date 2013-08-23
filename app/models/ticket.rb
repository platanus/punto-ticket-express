class Ticket < ActiveRecord::Base
  # attrs
  attr_accessible :ticket_type_id

  # relationship
  belongs_to :ticket_type
  belongs_to :transaction
  has_one :user, through: :transaction
  has_one :event, through: :ticket_type

  # validations
  validates :ticket_type_id, presence: true
  validate :is_ticket_type_valid?
  validate :available_tickets?

  #scopes
  scope :processing, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.processing])
  scope :completed, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.completed])
  scope :inactives, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.inactive])
  scope :by_type, lambda {|ticket_type_id| where(ticket_type_id: ticket_type_id)}

  #delegates

  #ticket_type
  delegate :name, to: :ticket_type, prefix: true, allow_nil: true
  delegate :quantity, to: :ticket_type, prefix: true, allow_nil: true
  delegate :price, to: :ticket_type, prefix: true, allow_nil: true
  delegate :available_tickets_count, to: :ticket_type, prefix: false, allow_nil: true
  #transaction
  delegate :user_email, to: :transaction, prefix: true, allow_nil: true
  delegate :payment_status, to: :transaction, prefix: false, allow_nil: true
  #event
  delegate :user_id, to: :event, prefix: true, allow_nil: true
  delegate :name, to: :event, prefix: true, allow_nil: true
  delegate :start_time, to: :event, prefix: true, allow_nil: true
  delegate :end_time, to: :event, prefix: true, allow_nil: true
  delegate :address, to: :event, prefix: true, allow_nil: true

  private

    def available_tickets?
      if self.new_record? and (!self.ticket_type or self.available_tickets_count < 1)
        self.errors.add(:ticket_type_id, :ticket_quantity_greater_than_type_quantity)
        return false
      end
    end

    def is_ticket_type_valid?
      if TicketType.find_by_id(self.ticket_type_id).nil?
        self.errors.add(:ticket_type_id, :invalid_ticket_type_given)
        return false
      end
    end
end
