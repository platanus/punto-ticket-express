require 'spec_helper'

describe Promotion do
  let(:promotion) { create(:percent_promotion) }

  describe "Relations" do
    it do
      should belong_to(:promotable)
      should have_many(:tickets)
      should have_many(:transactions)
    end
  end

  describe "Validations" do
    it do
      should validate_presence_of(:name)
      should validate_presence_of(:promotion_type)
      should validate_presence_of(:promotable_id)
      should validate_presence_of(:promotable_type)
      should validate_presence_of(:promotion_type_config)
      should validate_presence_of(:enabled)
    end

    it "can't be updated" do
      expect { Promotion.update(promotion.id, name: "Leandro") }.to raise_error(PTE::Exceptions::PromotionError)
      expect { promotion.update_attributes(name: "Leandro") }.to raise_error(PTE::Exceptions::PromotionError)
      expect { promotion.destroy }.to raise_error(PTE::Exceptions::PromotionError)
    end
  end

  describe "#event" do
    it "returns event when promotion it's over an event" do
      prom = create(:promotion)
      expect(prom.event).to be_kind_of(Event)
    end

    it "returns event when promotion it's over ticket type" do
      prom = create(:event_promotion)
      expect(prom.event).to be_kind_of(Event)
    end
  end

  describe "#get_percent_discount_amount" do
    it "returns 0 when no price given" do
      promotion = create(:percent_promotion)
      expect(promotion.get_percent_discount_amount(nil)).to eq(0.0)
    end

    it "returns discount equals 100" do
      promotion = create(:percent_promotion, promotion_type_config: 10)
      expect(promotion.get_percent_discount_amount(1000)).to eq(100.0)
    end

    it "returns 0 when not promotion_type_config given" do
      promotion = create(:percent_promotion, promotion_type_config: nil)
      expect(promotion.get_percent_discount_amount(1000)).to eq(0.0)
    end
  end

  describe "#get_amount_discount_amount" do

    it "" do
      pending
    end

  end

  describe "#get_nx1_amount" do

    it "" do
      pending
    end

  end
end
