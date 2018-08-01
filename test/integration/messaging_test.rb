require 'test_helper'

class MessagingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other = users(:archer)
  end

  test "message interface" do
    get 
    log_in_as(@user)
  end

end
