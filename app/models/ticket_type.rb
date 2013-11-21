class TicketType < ActiveRecord::Base
  attr_accessible :event_id, :name, :price, :quantity, :event_id
  attr_accessor :bought_quantity

  validate :is_price_valid?
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  before_destroy :can_destroy?

  belongs_to :event
  has_one :user, through: :event
  has_many :tickets
  has_many :promotions, as: :promotable

  delegate :fixed_fee, to: :event, prefix: true, allow_nil: true
  delegate :promotions, to: :event, prefix: true, allow_nil: true
  delegate :percent_fee, to: :event, prefix: true, allow_nil: true

  def available_tickets_count
  	unavailable_quantity = Ticket.by_type(self.id).processing.count
    unavailable_quantity += Ticket.by_type(self.id).completed.count
  	self.quantity - unavailable_quantity
  end

  def self.ticket_types_for_same_event? ticket_types
    ticket_types.map { |tt| tt.event_id }.uniq.one?
  end

  def bought_quantity_price
    (self.bought_quantity.to_d * self.price.to_d) rescue 0.0
  end

  def sold_amount
    (self.sold_tickets_count.to_d * self.price.to_d) rescue 0.0
  end

  def discount_amount
    self.tickets.completed.inject(0.0) do |total, ticket|
      total += ticket.discount
    end
  end

  def raised_amount
    self.sold_amount - self.total_fee - self.discount_amount
  end

  def sold_tickets_count
    self.tickets.completed.count
  end

  def total_fee
    (self.fixed_fee + percent_fee) rescue 0.0
  end

  def fixed_fee
    (self.sold_tickets_count.to_d * self.event_fixed_fee.to_d) rescue 0.0
  end

  def percent_fee
    (self.sold_amount.to_d * self.event_percent_fee.to_d / 100.0) rescue 0.0
  end

  def percent_fee_over_price
    (self.price.to_d * self.event_percent_fee.to_d / 100.0) rescue 0.0
  end

  def price_minus_fee
    safe_fixed_fee = self.event_fixed_fee || 0.0
    safe_price = self.price || 0.0
    safe_price.to_d - safe_fixed_fee.to_d - self.percent_fee_over_price
  end

  def all_promotions
    self.promotions + self.event_promotions
  end

  # Returns the ticket type's more convenient promotion
  # Promotions will be evaluated if activation_code is nil
  # Promotions will be evaluated if promotion_type = amount_discount or percent_discount only
  # Event promotions for this ticket type will be evaluated too.
  #
  # @return [Float]
  def most_convenient_promotion
    promos = []

    self.all_promotions.reject do |promo|
      next if !promo.activation_code.to_s.empty? or promo.is_nx1?
      promos << promo
    end

    Promotion.most_convenient_promotion(promos, self.price)
  end

  # Returns the ticket type's price minus more convenient promotion amount
  # If ticket type is not related with any promotion the value returned will
  # be equals to ticket type's price.
  #
  # @return [Float]
  def promotion_price
    convenient_promo = self.most_convenient_promotion
    discount = convenient_promo.discount(self.price_minus_fee) rescue 0.0
    amount = self.price_minus_fee || 0.0
    amount - discount
  end

  private

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end
    end

    def is_price_valid?
      if self.price_minus_fee <= 0
        errors.add(:price, :price_too_low)
        return false
      end
    end
end
