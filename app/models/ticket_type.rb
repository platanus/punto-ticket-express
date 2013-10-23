class TicketType < ActiveRecord::Base
  attr_accessible :event_id, :name, :price, :quantity, :event_id

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_destroy :can_destroy?

  belongs_to :event
  has_many :tickets
  has_many :promotions

  delegate :fixed_fee, to: :event, prefix: true, allow_nil: true
  delegate :percent_fee, to: :event, prefix: true, allow_nil: true

  def available_tickets_count
  	unavailable_quantity = Ticket.by_type(self.id).processing.count
    unavailable_quantity += Ticket.by_type(self.id).completed.count
  	self.quantity - unavailable_quantity
  end

  def self.ticket_types_for_same_event? ticket_types
    ticket_types.map { |tt| tt.event_id }.uniq.one?
  end

  def sold_amount
    (self.sold_tickets_count.to_d * self.price.to_d) rescue 0.0
  end

  def sold_tickets_count
    self.tickets.completed.count
  end

  def fixed_fee
    (self.sold_tickets_count.to_d * self.event_fixed_fee.to_d) rescue 0.0
  end

  def percent_fee
    (self.sold_amount.to_d * self.event_percent_fee.to_d / 100.0) rescue 0.0
  end

  private

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end
    end
end
