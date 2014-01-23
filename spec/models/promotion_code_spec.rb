require 'spec_helper'

describe PromotionCode do
  let(:promotion_code) { create(:promotion_code) }

  describe "Relations" do
    it do
      should belong_to(:promotion)
      should belong_to(:user)
    end
  end

  describe "Validations" do
    it do
      should validate_presence_of(:code)
      should validate_presence_of(:promotion)
    end

    it "fails with same code added twice for same promotion"do
      promotion = create(:promotion)
      create(:promotion_code, code: 'SAME_CODE', promotion: promotion)
      promotion_code = build(:promotion_code, :code => 'SAME_CODE', promotion: promotion)
      expect(promotion_code.save).to be_false
      promotion_code.errors.messages[:code].should include(
        I18n.t("activerecord.errors.models.promotion_code.attributes.code.repeated_code_for_promotion"))
    end
  end
end
