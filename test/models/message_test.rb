require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @message = Message.create(sender_id: 1, recipient_id: 3, content: "test")
  end

  test "should be valid" do
    assert @message.content, "test"
  end

end
