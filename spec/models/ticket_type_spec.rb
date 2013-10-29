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
      should validate_presence_of(:event_id)
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

    it "applies percent discount when percent promo is bigger than amount promo" do
      create(:percent_promotion, promotable: @ticket_type, promotion_type_config: 20, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 100, activation_code: nil)
      expect(@ticket_type.promotion_price).to eq(800)
    end

    it "applies amount discount when amount promo is bigger than discount promo" do
      create(:percent_promotion, promotable: @ticket_type, promotion_type_config: 10, activation_code: nil)
      create(:amount_promotion, promotable: @ticket_type, promotion_type_config: 200, activation_code: nil)
      expect(@ticket_type.promotion_price).to eq(800)
    end

    it "applies 0 discount when no promotions given" do
      expect(@ticket_type.promotion_price).to eq(1000)
    end

  end

end
