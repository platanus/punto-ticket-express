require 'spec_helper'

describe Promotion do
  let(:promotion) { create(:percent_promotion) }

  describe "Relations" do
    it do
      should belong_to(:ticket_type)
      should have_one(:event)
      should have_many(:tickets)
      should have_many(:transactions)
    end
  end

  describe "Validations" do
    it do
      should validate_presence_of(:name)
      should validate_presence_of(:promotion_type)
      should validate_presence_of(:ticket_type_id)
      should validate_presence_of(:promotion_type_config)
      should validate_presence_of(:enabled)
    end
  end

  it "can't be updated" do
    expect { Promotion.update(promotion.id, name: "Leandro") }.to raise_error(PTE::Exceptions::PromotionError)
    expect { promotion.update_attributes(name: "Leandro") }.to raise_error(PTE::Exceptions::PromotionError)
    expect { promotion.destroy }.to raise_error(PTE::Exceptions::PromotionError)
  end

end
