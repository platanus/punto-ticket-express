class Promotion < ActiveRecord::Base
  attr_accessible :activation_code, :end_date, :limit, :name, :enabled,
  :promotion_type, :promotion_type_config, :start_date, :ticket_type_id

  validates_presence_of :name, :promotion_type, :ticket_type_id, :promotion_type_config, :enabled

  belongs_to :ticket_type
  has_one :event, through: :ticket_type
  has_many :tickets
  has_many :transactions, through: :tickets, uniq: true

  scope :enabled, where(enabled: true)
  scope :amount, where(promotion_type: :amount_discount)
  scope :percent, where(promotion_type: :percent_discount)

  before_destroy :cancel_destroy

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
