class AddFollowedNoticeToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :followed_notice, :boolean, default: false
  end
end
