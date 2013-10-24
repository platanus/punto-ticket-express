require 'spec_helper'

describe TicketType do
  let(:ticket_type) { create(:ticket_type, price: 1000) }

  describe "#promotion_price" do

    it "applies percent discount when discount promo is bigger than amount promo" do
      create(:percent_promotion, ticket_type_id: ticket_type.id, promotion_type_config: 20)
      create(:amount_promotion, ticket_type_id: ticket_type.id, promotion_type_config: 100)
      expect(ticket_type.promotion_price).to eq(800)
    end

    it "applies amount discount when amount promo is bigger than discount promo" do
      create(:percent_promotion, ticket_type_id: ticket_type.id, promotion_type_config: 10)
      create(:amount_promotion, ticket_type_id: ticket_type.id, promotion_type_config: 200)
      expect(ticket_type.promotion_price).to eq(800)
    end

    it 'applies 0 discount when no promotions given' do
      expect(ticket_type.promotion_price).to eq(1000)
    end

  end

end
