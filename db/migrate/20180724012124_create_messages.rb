class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :sender_id
      t.integer :recipient_id
      t.timestamps
    end
    add_index :messages, [:sender_id, :recipient_id, :created_at]
  end
end
