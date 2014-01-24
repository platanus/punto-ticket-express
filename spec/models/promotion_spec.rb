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

  describe "#apply" do

    it "returns false with no tickets given" do
      promotion = create(:promotion)
      expect(promotion.apply(nil)).to be_false
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when tries to apply disabled promo on tickets" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, enabled: false, promotion_type_config: 20, promotable: type, activation_code: nil)
      expect(promotion.apply([ticket_one, ticket_two])).to be_false
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when tickets count is lower than n value defined for nx1 promotions" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:nx1_promotion, enabled: true, promotion_type_config: 3, promotable: type, activation_code: nil)
      expect(promotion.apply([ticket_one, ticket_two])).to be_false #2 tickets with n = 3
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when promo event != ticket event" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      event_two = create(:event)
      type_two = create(:ticket_type, quantity: 10, event: event_two, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type_two)
      promotion = create(:percent_promotion, enabled: true, promotion_type_config: 20, promotable: type, activation_code: nil)
      expect(promotion.apply([ticket_one, ticket_two])).to be_false
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when activation code not matches with validation code" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, activation_code: "CODE", validation_code: "DIFFERENTCODE", enabled: true, promotion_type_config: 20, promotable: type)
      expect(promotion.apply([ticket_one, ticket_two])).to be_false
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when today is lower than start_date" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, start_date: Date.today + 4.days, end_date: Date.today + 8.days, activation_code: nil, enabled: true, promotion_type_config: 20, promotable: type)
      expect(promotion.apply([ticket_one, ticket_two])).to be_false
      expect(promotion.tickets.size).to eq(0)
    end

    it "returns false when exceded limit" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      transaction = create(:transaction, payment_status: PTE::PaymentStatus.completed)
      promotion = create(:percent_promotion, activation_code: nil, limit: 2, enabled: true, promotion_type_config: 20, promotable: type)
      ticket_one = create(:ticket, ticket_type: type, transaction: transaction, promotion: promotion)
      ticket_two = create(:ticket, ticket_type: type, transaction: transaction, promotion: promotion)
      ticket_three = create(:ticket, ticket_type: type)
      expect(promotion.apply([ticket_three])).to be_false
      expect(promotion.tickets.size).to eq(2)
    end

    it "returns true when activation code matches with validation code" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, id: 1, activation_code: "CODE", validation_code: "CODE", enabled: true, promotion_type_config: 20, promotable: type)
      expect(promotion.apply([ticket_one, ticket_two])).to be_true
      expect(ticket_one.promotion.id).to eq(promotion.id)
      expect(ticket_two.promotion.id).to eq(promotion.id)
    end

    it "returns true when PromotionObject's code matches with validation code", flag: true do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, id: 1, validation_code: "CODE2", enabled: true, promotion_type_config: 20, promotable: type)
      create(:promotion_code, id: 1, code: "CODE1", promotion: promotion, user_id: nil)
      create(:promotion_code, id: 2, code: "CODE2", promotion: promotion, user_id: nil)
      user = create(:user, id: 22)
      expect(promotion.apply([ticket_one, ticket_two], user.id)).to be_true
      expect(ticket_one.promotion.id).to eq(promotion.id)
      expect(ticket_two.promotion.id).to eq(promotion.id)
      expect(PromotionCode.find(1).user).to be_nil
      expect(PromotionCode.find(2).user.id).to eq(user.id)
    end

    it "returns true when uses nx1 promotion with right config" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      ticket_three = create(:ticket, ticket_type: type)
      promotion = create(:nx1_promotion, enabled: true, promotion_type_config: 2, promotable: type, activation_code: nil)
      expect(promotion.apply([ticket_one, ticket_two, ticket_three])).to be_true #3 tickets with n = 2
      expect(ticket_one.promotion.id).to eq(promotion.id)
      expect(ticket_two.promotion.id).to eq(promotion.id)
      expect(ticket_three.promotion).to be_nil
    end

    it "returns true when uses percent promo" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:percent_promotion, id: 1, activation_code: nil, enabled: true, promotion_type_config: 20, promotable: type)
      expect(promotion.apply([ticket_one, ticket_two])).to be_true
      expect(ticket_one.promotion.id).to eq(promotion.id)
      expect(ticket_two.promotion.id).to eq(promotion.id)
    end

    it "returns true when uses amount promo" do
      event = create(:event)
      type = create(:ticket_type, quantity: 10, event: event, price: 1000)
      ticket_one = create(:ticket, ticket_type: type)
      ticket_two = create(:ticket, ticket_type: type)
      promotion = create(:amount_promotion, id: 1, activation_code: nil, enabled: true, promotion_type_config: 200, promotable: type)
      expect(promotion.apply([ticket_one, ticket_two])).to be_true
      expect(ticket_one.promotion.id).to eq(promotion.id)
      expect(ticket_two.promotion.id).to eq(promotion.id)
    end
  end
end
