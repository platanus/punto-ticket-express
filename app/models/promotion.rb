class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :enabled,
  :promotion_type, :promotion_type_config, :start_date, :promotable_id, :promotable_type, :promotable

  attr_accessor :validation_code

  belongs_to :promotable, polymorphic: true
  has_many :tickets
  has_many :promotion_codes
  has_many :transactions, through: :tickets, uniq: true

  validates_presence_of :name, :promotion_type, :promotable_id,
    :promotable_type, :end_date, :start_date, :promotion_type_config

  validates :promotion_type_config, presence: true,
    numericality: { greater_than_or_equal_to: 2, only_integer: true },
    if: Proc.new { |promo| promo.is_nx1? }

  validates :promotion_type_config, presence: true,
    numericality: { greater_than: 0 },
    if: Proc.new { |promo| promo.is_amount_discount? }

  validates :promotion_type_config, presence: true,
    numericality: { greater_than: 0, less_than_or_equal_to: 100 },
    if: Proc.new { |promo| promo.is_percent_discount? }

  validates :start_date, date: true
  validates :end_date, date: true
  validate :dates_range_valid?

  scope :amount, where(promotion_type: :amount_discount)
  scope :percent, where(promotion_type: :percent_discount)
  scope :with_activation_code, where("activation_code IS NOT NULL OR activation_code <> ''")
  scope :without_activation_code, where("activation_code IS NULL OR activation_code = ''")

  before_destroy :cancel_destroy

  delegate :user, to: :promotable, prefix: false, allow_nil: true

  # Defines a single instance method with structure:
  # is_[promo_type]? Example: is_amount_discount?
  # for each type defined on TYPES array.
  PTE::PromoType::TYPES.each do |type_name|
    self.instance_eval do
      define_method("is_#{type_name}?") do
        eval("PTE::PromoType.#{type_name}") == self.promotion_type
      end
    end
  end

  def enable
    self.update_column(:enabled, true)
  end

  def disable
    self.update_column(:enabled, false)
  end

  # Assigns promotion to tickets. This method will retrun false if:
  # - No tickets given
  # - Tries to apply disabled promo on tickets
  # - Tries to apply not available promo on tickets
  # - Tickets count is lower than n value defined for nx1 promotions
  # - Promo event != ticket event
  # - Activation code not matches with validation code.
  #
  # @param type_tickets [Array] Tickets collection
  # @return [Boolean]
  def apply type_tickets
    begin
      ActiveRecord::Base.transaction do
        raise PTE::Exceptions::PromotionError.new(
          "no tickets given") unless type_tickets
        raise PTE::Exceptions::PromotionError.new(
          "trying to apply disabled promo on tickets") unless self.enabled
        raise PTE::Exceptions::PromotionError.new(
          "trying to apply unavailable promo on tickets") unless self.is_promo_available?
        unless self.is_valid_for_qty?(type_tickets.size)
          raise PTE::Exceptions::PromotionError.new(
            "tickets count lower than promotion_type_config on nx1 promo")
        end
        type_tickets.each do |ticket|
          if self.event.id != ticket.event.id
            raise PTE::Exceptions::PromotionError.new(
              "promo event != ticket event")
          end

          unless self.is_activation_code_valid?
            raise PTE::Exceptions::PromotionError.new(
              "activation code not matching with validation code")
          end
          self.tickets << ticket unless self.is_nx1?
        end

        type_tickets.each_with_index do |ticket, idx|
          self.tickets << ticket if idx < promotion_type_config.to_i
        end if self.is_nx1?
      end

      return true

    rescue Exception => e
      Rails.logger.error(e.message.red)
      return false
    end
  end

  # Loads discount attr based on promotion type
  #
  # @param price [Decimal]
  # @return [Decimal]
  def discount price = nil
    result = 0.0

    if self.is_percent_discount?
      result = self.get_percent_discount_amount(price)

    elsif self.is_amount_discount?
      result = self.get_amount_discount_amount

    elsif self.is_nx1?
      result = self.get_nx1_amount(price)

    else
      raise PTE::Exceptions::PromotionError.new(
        "Invalid promotion type given")
    end

    result || 0.0
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

  # Calculates discount dividing price by N value defined by promotion
  #
  # @param price [Decimal]
  # @return [Decimal]
  def get_nx1_amount price
    (price.to_d / self.promotion_type_config.to_d) rescue 0.0
  end

  # If promotion is related with event this method will return that event
  # If promotion is related with ticket type will return  ticket type's event
  #
  # @return [Event]
  def event
    return nil unless self.promotable
    return promotable unless self.related_with_ticket_type?
    self.promotable.event
  end

  def related_with_ticket_type?
    self.promotable.kind_of? TicketType
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
      next unless promo.is_promo_available? and promo.enabled
      if convenient_promo.nil? or
        (promo.discount.to_d > convenient_promo.discount(price))
        convenient_promo = promo
      end
    end

    convenient_promo
  end

  # Verifies if promotions is available checking:
  # - if today is between start and end dates.
  # - if sold tickets count is lower than promotion limit.
  #
  # @return [Boolean]
  def is_promo_available?
    return false if self.is_out_of_range?
    !self.is_limit_exceeded?
  end

  def is_out_of_range?
    self.start_date and self.end_date and
    (DateTime.now < self.start_date or DateTime.now > self.end_date)
  end

  def is_valid_for_qty? quantity
    return true unless self.is_nx1?
    (quantity >= self.promotion_type_config.to_i)
  end

  def is_limit_exceeded?
    self.limit and self.sold_tickets.count >= self.limit
  end

  def is_activation_code_valid?
    (self.activation_code.to_s.empty? or
      (self.activation_code.to_s == self.validation_code.to_s))
  end

  def sold_tickets
    self.tickets.completed
  end

  def hex_activation_code
    return nil if self.activation_code.to_s.empty?
    Digest::MD5.hexdigest(self.activation_code)
  end

  def dates_range_valid?
    return true if start_date.nil? or end_date.nil?

    if end_date < start_date
      errors.add(:end_date, :end_date_lower_than_start_date)
    end
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
