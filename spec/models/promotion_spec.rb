require 'spec_helper'

describe Promotion do

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
    end
  end

end
