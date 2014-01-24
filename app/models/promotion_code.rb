class PromotionCode < ActiveRecord::Base
  attr_accessible :code, :user_id, :group_number

  belongs_to :user
  belongs_to :promotion

  validates_presence_of :promotion, :code
  validates_format_of :code, with: /^[0-9a-zA-Z]*$/,
  	:message => I18n.t("activerecord.errors.models.promotion_code.attributes.code.invalid_format")
  validate :unique_code_for_promotion

  scope :unused, where("promotion_codes.user_id IS NULL")

  private

    def unique_code_for_promotion
      return true if !self.promotion or !self.code
      query = self.promotion.promotion_codes.where(code: self.code)
      query = query.where(["promotion_codes.id != ?", self.id]) if self.id
      errors.add(:code, :repeated_code_for_promotion) if query.count > 0
    end
end
