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
      should validate_presence_of(:start_date)
      should validate_presence_of(:end_date)
      should validate_presence_of(:promotion_type)
      should validate_presence_of(:promotable_id)
      should validate_presence_of(:promotable_type)
      should validate_presence_of(:promotion_type_config)
    end

    it "can't be destroyed" do
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

  describe "#discount" do
    it "returns 0 when no price given and type is percent" do
      promotion = create(:percent_promotion)
      expect(promotion.discount(nil)).to eq(0.0)
    end

    it "returns discount equals 100 and type is percent" do
      promotion = create(:percent_promotion, promotion_type_config: 10)
      expect(promotion.discount(1000)).to eq(100.0)
    end

    it "returns discount equals 200 and type is amount" do
      promotion = create(:amount_promotion, promotion_type_config: 200)
      expect(promotion.discount).to eq(200.0)
    end

    it "returns 0 when no price given and type is nx1" do
      promotion = create(:nx1_promotion)
      expect(promotion.discount(nil)).to eq(0.0)
    end

    it "returns discount equals 500 and type is nx1" do
      promotion = create(:nx1_promotion, promotion_type_config: 2)
      expect(promotion.discount(1000)).to eq(500.0)
    end
  end
end
