require 'spec_helper'

describe TicketType do

  before do
    event = create(:event, percent_fee: 20, fixed_fee: 50)
    @ticket_type = create(:ticket_type, price: 1000, quantity: 10, event: event)
    completed_transaction = create(:completed_transaction)
    create(:ticket, ticket_type: @ticket_type, transaction: completed_transaction)
    create(:ticket, ticket_type: @ticket_type, transaction: completed_transaction)
    create(:ticket, ticket_type: @ticket_type, transaction: completed_transaction)
    inactive_transaction = create(:inactive_transaction)
    create(:ticket, ticket_type: @ticket_type, transaction: inactive_transaction)
    processing_transaction = create(:transaction)
    create(:ticket, ticket_type: @ticket_type, transaction: processing_transaction)
  end

  describe "Relations" do
    it do
      should belong_to(:event)
      should have_many(:tickets)
      should have_many(:promotions)
    end
  end

  describe "Validations" do
    it do
      should validate_presence_of(:name)
      should validate_presence_of(:price)
      should validate_presence_of(:quantity)
      should validate_numericality_of(:price).is_greater_than_or_equal_to(0)
      should validate_numericality_of(:quantity).is_greater_than(0)
    end
  end

  describe "#available_tickets_count" do

    it "returns 7 available tickets" do
      expect(@ticket_type.available_tickets_count).to eq(6)
    end

  end

  describe "#sold_amount" do

    it "returns 3000 as sold amount" do
      expect(@ticket_type.sold_amount).to eq(3000)
    end

  end

  describe "#sold_tickets_count" do

    it "returns 3 sold tickets" do
      expect(@ticket_type.sold_tickets_count).to eq(3)
    end

  end

  describe "#fixed_fee" do

    it "returns 150 as fixed_fee" do
      expect(@ticket_type.fixed_fee).to eq(150.0)
    end

  end

  describe "#percent_fee" do

    it "returns 600 as percent_fee" do
      expect(@ticket_type.percent_fee).to eq(600.0)
    end

  end

  describe "#percent_fee_over_price" do

    it "returns 200 percent_fee_over_price" do
      expect(@ticket_type.percent_fee_over_price).to eq(200.0)
    end

  end

  describe "#price_minus_fee" do

    it "returns 750 as price_minus_fee" do
      expect(@ticket_type.price_minus_fee).to eq(750.0)
    end

  end

  describe "#all_promotions" do

    it "returns type and event promotions" do
      create(:amount_promotion)
      create(:amount_promotion, promotable: @ticket_type)
      create(:amount_promotion, promotable: @ticket_type.event)
      create(:percent_promotion, promotable: @ticket_type.event)
      create(:nx1_promotion, promotable: @ticket_type)
      expect(@ticket_type.all_promotions.count).to be(4)
    end

  end

  describe "#ticket_types_for_same_event?" do

    it "returns false when ticket types are from different events" do
      other_event = create(:event)
      other_ticket_type = create(:ticket_type, event: other_event)
      expect(TicketType.ticket_types_for_same_event?([@ticket_type, other_ticket_type])).not_to be_true
    end

    it "returns true when ticket types are from same events" do
      other_ticket_type = create(:ticket_type, event: @ticket_type.event)
      expect(TicketType.ticket_types_for_same_event?([@ticket_type, other_ticket_type])).to be_true
    end

  end

  describe "#promotion_price" do

    it "applies ticket type percent discount" do
      create(:percent_promotion, promotable: @ticket_type, promotion_type_config: 20, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 100, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type.event, promotion_type_config: 150, activation_code: nil)
      expect(@ticket_type.promotion_price.to_i).to eq(600)
    end

    it "applies ticket type amount discount" do
      create(:percent_promotion, promotable: @ticket_type, promotion_type_config: 10, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type.event, promotion_type_config: 150, activation_code: nil)
      expect(@ticket_type.promotion_price.to_i).to eq(550)
    end

    it "applies event promotion over type promotions" do
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200, activation_code: nil)
      create(:nx1_promotion, promotable: @ticket_type, promotion_type_config: 3, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type.event, promotion_type_config: 300, activation_code: nil)
      expect(@ticket_type.promotion_price.to_i).to eq(450)
    end

    it "applies 0 discount when no promotions given" do
      expect(@ticket_type.promotion_price.to_i).to eq(750)
    end

    it "ignores nx1 discount" do
      create(:nx1_promotion, promotable: @ticket_type.event, promotion_type_config: 500, activation_code: nil)
      expect(@ticket_type.promotion_price.to_i).to eq(750)
    end

    it "ignores promotion with defined activation code" do
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200, activation_code: "LEANSCODE")
      expect(@ticket_type.promotion_price.to_i).to eq(750)
    end

    it "ignores promotions out defined date range" do
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200,
        activation_code: nil, start_date: (Date.today + 2.days), end_date: (Date.today + 4.days))
      expect(@ticket_type.promotion_price.to_i).to eq(750)
    end

    it "ignores promotions with exceeded limit" do
      promo = create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200,
        activation_code: nil, limit: 2)
      transaction = create(:completed_transaction)
      create(:ticket, promotion_id: promo.id, ticket_type: @ticket_type, transaction: transaction)
      create(:ticket, promotion_id: promo.id, ticket_type: @ticket_type, transaction: transaction)
      expect(@ticket_type.promotion_price.to_i).to eq(750)
    end

  end

end
