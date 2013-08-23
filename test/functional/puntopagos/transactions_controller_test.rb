require 'test_helper'

class Puntopagos::TransactionsControllerTest < ActionController::TestCase
  test "should get notification" do
    get :notification
    assert_response :success
  end

  test "should get error" do
    get :error
    assert_response :success
  end

  test "should get success" do
    get :success
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
