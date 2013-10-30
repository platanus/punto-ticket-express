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

  PTE::PromoType::TYPES.each do |type_name|
    self.instance_eval do
      define_method("is_#{type_name}?") do
        eval("PTE::PromoType.#{type_name}") == self.promotion_type
      end
    end
  end

  def get_percent_discount_amount price
    (self.promotion_type_config.to_d * price.to_d / 100.0) rescue 0.0
  end

  def get_amount_discount_amount
    self.promotion_type_config.to_d rescue 0.0
  end

  def get_nx1_amount price
    (price.to_d / self.promotion_type_config.to_i) rescue 0.0
  end

  def event
    return promotable unless self.promotable_type == 'TicketType'
    self.promotable.event
  end

  def self.most_convenient_promotion promotions, price
    convenient_promo = nil
    # TODO: How about enabled and disabled promotions?

    promotions.each do |promo|
      next unless promo.is_promo_available?

      if promo.is_percent_discount?
        promo.discount = promo.get_percent_discount_amount(price)

      elsif promo.is_amount_discount?
        promo.discount = promo.get_amount_discount_amount

      elsif promo.is_nx1?
        promo.discount = promo.get_nx1_amount(price)

      else
        raise PTE::Exceptions::PromotionError.new(
          "Invalid promotion type given")
      end

      if convenient_promo.nil? or
        (promo.discount.to_d > convenient_promo.discount.to_d)
        convenient_promo = promo
      end
    end

    convenient_promo
  end

  def is_promo_available?
    # TODO: it's not available if now is lower than start date or bigger than end_date
    # it's not available if sold tickets count with this promotion it's bigger than self.limit
    true
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
