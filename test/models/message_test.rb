require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @message = Message.create(sender_id: 1, recipient_id: 3, content: "test")
  end

  test "should be valid" do
    assert_equal @message.content, "test"
  end

  test "message should not too long" do
    long_message = Message.create(sender_id: 1, recipient_id: 3, content: "t" * 1001 )
    assert_not long_message.valid?
  end
end
