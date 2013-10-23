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

end
