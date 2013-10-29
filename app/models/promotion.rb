class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :enabled,
  :promotion_type, :promotion_type_config, :start_date, :promotable_id, :promotable_type

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

  def event
    return promotable unless self.promotable_type == 'TicketType'
    self.promotable.event
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
