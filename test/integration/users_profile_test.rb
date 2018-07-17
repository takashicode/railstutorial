require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
    @archer = users(:archer)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination',count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
    #assert_select "a[href=?]", ’/’, count: 1
    get user_path(@user)
    assert_select 'strong#following',@user.active_relationships.count.to_s
    assert_select 'strong#followers',@user.passive_relationships.count.to_s
  end

  test "home desplay stats" do
    #following number should appear in home
    log_in_as @user
    get root_path
    assert_select 'strong#following',@user.active_relationships.count.to_s
    assert_select 'strong#followers',@user.passive_relationships.count.to_s
    #assert_match "0 following", response.body
    #assert_difference "@user.active_relationships.count" , 1 do
      @user.follow @archer
    #end
    get root_path
    assert_select 'strong#following',@user.active_relationships.count.to_s
  end
end
