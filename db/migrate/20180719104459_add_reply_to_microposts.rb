class AddReplyToMicroposts < ActiveRecord::Migration[5.2]
  def change
    add_column :microposts, :in_reply_to, :integer, default: nil
  end
end
