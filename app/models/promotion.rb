class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :enabled,
  :promotion_type, :promotion_type_config, :start_date, :promotable_id, :promotable_type

  attr_accessor :discount

  validates_presence_of :name, :promotion_type, :promotion_type_config, :enabled, :promotable_id, :promotable_type

  belongs_to :promotable, polymorphic: true
  has_many :tickets
  has_many :transactions, through: :tickets, uniq: true

  scope :enabled, where(enabled: true)
  scope :amount, where(promotion_type: :amount_discount)
  scope :percent, where(promotion_type: :percent_discount)
  scope :with_activation_code, where("activation_code IS NOT NULL OR activation_code <> ''")
  scope :without_activation_code, where(activation_code: nil)

  before_destroy :cancel_destroy

  delegate :user, to: :promotable, prefix: false, allow_nil: true

  # Defines a single method with structure:
  # is_[promo_type]? Example: is_amount_discount?
  # for each type defined on TYPES array.
  PTE::PromoType::TYPES.each do |type_name|
    self.instance_eval do
      define_method("is_#{type_name}?") do
        eval("PTE::PromoType.#{type_name}") == self.promotion_type
      end
    end
  end

  # Loads discount attr based on promotion type
  #
  # @param price [Decimal]
  # @return [Decimal]
  def load_discount price = nil
    if self.is_percent_discount?
      self.discount = self.get_percent_discount_amount(price)

    elsif self.is_amount_discount?
      self.discount = self.get_amount_discount_amount

    elsif self.is_nx1?
      self.discount = self.get_nx1_amount(price)

    else
      raise PTE::Exceptions::PromotionError.new(
        "Invalid promotion type given")
    end

    self.discount || 0.0
  end

  # Calculates discount based on % defined by promotion and given price.
  #
  # @param price [Decimal]
  # @return [Decimal]
  def get_percent_discount_amount price
    (self.promotion_type_config.to_d * price.to_d / 100.0) rescue 0.0
  end

  # Calculates fixed discount amount defined by promotion
  #
  # @return [Decimal]
  def get_amount_discount_amount
    self.promotion_type_config.to_d rescue 0.0
  end

  # Calculates discount multiping price with N value defined by promotion minus 1 x price
  #
  # @param price [Decimal]
  # @return [Decimal]
  def get_nx1_amount price
    (self.promotion_type_config.to_i * price - price) rescue 0.0
  end

  # If promotion is related with event this method will return that event
  # If promotion is related with ticket type will return  ticket type's event
  #
  # @return [Event]
  def event
    return nil unless self.promotable
    return promotable unless self.promotable.kind_of? TicketType
    self.promotable.event
  end

  # Selects, in a group of promotions, the most convenient promo.
  # The most convenient promo gives the higher discount over given price.
  #
  # @param promotions [Array] Collection with Promotion objects.
  # @param price [Decimal] Price is necessary to calculate discount in some promotions
  # @return [Promotion] with loaded discount attr.
  def self.most_convenient_promotion promotions, price = nil
    raise PTE::Exceptions::PromotionError.new("price not given") unless price
    convenient_promo = nil

    promotions.each do |promo|
      next unless promo.is_promo_available?
      promo.load_discount(price)
      if convenient_promo.nil? or
        (promo.discount.to_d > convenient_promo.discount.to_d)
        convenient_promo = promo
      end
    end

    convenient_promo
  end

  # Verifies if promotions is available checking:
  # - if promo is enabled
  # - if today is between start and end dates.
  # - if sold tickets count is lower than promotion limit.
  #
  # @return [Boolean]
  def is_promo_available?
    return false unless self.enabled

    if self.start_date and self.end_date and
      (Date.today < self.start_date or Date.today > self.end_date)
      return false
    end

    !self.limit or self.tickets.completed.count < self.limit
  end

  def update
    raise PTE::Exceptions::PromotionError.new(
      "Promotion instance can't be updated")
  end

  private

    def cancel_destroy
      raise PTE::Exceptions::PromotionError.new(
        "Promotion instance can't be destroyed")
    end
end
