require 'test_helper'

class ConfigurationControllerTest < ActionController::TestCase
  test "should get account" do
    get :account
    assert_response :success
  end

  test "should get producers" do
    get :producers
    assert_response :success
  end

  test "should get transactions" do
    get :transactions
    assert_response :success
  end

end
