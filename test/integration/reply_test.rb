require 'test_helper'

class ReplyTest < ActionDispatch::IntegrationTest
  def setup
    @replying = users(:michael)
    @replied  = users(:archer)
    @other    = users(:takashi)
    log_in_as(@replying)
  end
  # test "the truth" do
  #   assert true
  # end
  test "@reply should appear on other's microposts" do
    get user_path(@replied)
    assert_match "@reply",response.body
  end

  test "should show replied name" do
    get root_path
    post microposts_path, params: { micropost: { content: "reply test",
                                                 in_reply_to: @replied.id } }
    assert_redirected_to root_url
    follow_redirect!
    assert_match CGI.escapeHTML("@#{@replied.id}-#{@replied.name}"),
                    response.body
    get user_path(@replying)
    assert_match CGI.escapeHTML("@#{@replied.id}-#{@replied.name}"),
                    response.body
    session[:user_id] = nil
    log_in_as(@replied)
    get root_path
    assert_match CGI.escapeHTML("@#{@replied.id}-#{@replied.name}"),
                    response.body
    get user_path(@replying)
    assert_match CGI.escapeHTML("@#{@replied.id}-#{@replied.name}"),
                    response.body
    # @replying.microposts.create(content:     "reply to archer",
    #                             in_reply_to: @replied.id)
    session[:user_id] = nil
    log_in_as(@other)
    get user_path(@replying)
    assert_no_match CGI.escapeHTML("@#{@replied.id}-#{@replied.name}"),
                    response.body    
  end
end
