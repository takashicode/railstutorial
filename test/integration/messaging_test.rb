require 'test_helper'

class MessagingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other = users(:archer)
  end

  test "message interface" do
    get message_path
    assert_redirected_to login_path
    log_in_as(@user)
    get message_path
    assert_match @other.name, response.body
    get messages_user_path(@other)
    assert_select  'div.message-sent'
    assert_select  'div.message-received'
    assert_match  messages(:one).content, response.body
    assert_match  messages(:two).content, response.body
    assert_difference '@user.messages_with(@other.id).count', 1 do
      post messages_user_path(@other) ,params: { message: {sender_id:    @user.id,
                                                           recipient_id: @other.id,
                                                           content:      "foobar"} }
    end
    assert_match "foobar", response.body
    session[:user_id] = nil
    log_in_as(@other)
    get message_path
    assert_match @user.name, response.body
    get messages_user_path(@user)
    assert_select  'div.message-sent'
    assert_select  'div.message-received'
    assert_match  messages(:one).content, response.body
    assert_match  messages(:two).content, response.body
    assert_match "foobar", response.body
    # assert_difference '@other.chat_with.count', -1 do
    #   get message_path
    
    #   delete messages_user_path(@user)
    # end
    # get message_path
    # assert_match @user.name, response.body
  end

end
