class Ticket < ActiveRecord::Base
  attr_accessible :ticket_type_id, :transaction_id, :promotion_id

  belongs_to :ticket_type
  belongs_to :transaction
  belongs_to :promotion
  has_one :user, through: :transaction
  has_one :event, through: :ticket_type
  has_one :nested_resource, as: :nestable

  validates :ticket_type_id, presence: true
  validate :is_ticket_type_valid?
  validate :available_tickets?

  scope :processing, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.processing])
  scope :completed, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.completed])
  scope :inactives, joins(:transaction).where(["transactions.payment_status = ?", PTE::PaymentStatus.inactive])
  scope :by_type, lambda {|ticket_type_id| where(ticket_type_id: ticket_type_id)}

  delegate :name, to: :ticket_type, prefix: true, allow_nil: true
  delegate :quantity, to: :ticket_type, prefix: true, allow_nil: true
  delegate :price, to: :ticket_type, prefix: true, allow_nil: true
  delegate :available_tickets_count, to: :ticket_type, prefix: false, allow_nil: true
  delegate :fixed_fee, to: :ticket_type, prefix: true, allow_nil: true
  delegate :percent_fee, to: :ticket_type, prefix: true, allow_nil: true

  delegate :user_id, to: :transaction, prefix: true, allow_nil: true
  delegate :user_email, to: :transaction, prefix: true, allow_nil: true
  delegate :payment_status, to: :transaction, prefix: false, allow_nil: true

  delegate :user_id, to: :event, prefix: true, allow_nil: true
  delegate :name, to: :event, prefix: true, allow_nil: true
  delegate :start_time, to: :event, prefix: true, allow_nil: true
  delegate :end_time, to: :event, prefix: true, allow_nil: true
  delegate :address, to: :event, prefix: true, allow_nil: true
  delegate :producer, to: :event, prefix: true, allow_nil: true

  delegate :discount, to: :promotion, prefix: true, allow_nil: true

  alias_method :price, :ticket_type_price

  def fixed_fee
    self.ticket_type_fixed_fee.to_d rescue 0.0
  end

  def percent_fee
    (self.price.to_d * self.ticket_type_percent_fee.to_d / 100.0) rescue 0.0
  end

  def discount
    self.promotion_discount(self.price) || 0.0
  end

  def price_with_discount
    (self.price.to_d - discount.to_d) rescue 0.0
  end

  private

    def available_tickets?
      if self.new_record? and (!self.ticket_type or self.available_tickets_count < 1)
        self.errors.add(:ticket_type_id, :no_tickets_left)
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
