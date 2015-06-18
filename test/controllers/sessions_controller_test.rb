require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  test "should get login path" do
  	get :new
  	assert_response :success
  	assert_select "a", "Authenticate with Google!"
  	assert_select "header", { count: 0 }
  end
end
