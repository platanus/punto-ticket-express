# coding: utf-8
require 'test_helper'

class EventDecoratorTest < ActiveSupport::TestCase
  def setup
    @event = Event.new.extend EventDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
