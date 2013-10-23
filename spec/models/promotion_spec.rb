require 'spec_helper'

describe Promotion do

  describe "Relations" do
    it do
      should have_and_belong_to_many(:transactions)
      should belong_to(:ticket_type)
      should have_one(:event)
    end
  end

end
