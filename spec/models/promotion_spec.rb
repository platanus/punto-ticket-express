require 'spec_helper'

describe Promotion do

  describe "Relations" do
    it do
      should have_and_belong_to_many(:transactions)
    end
  end

end
