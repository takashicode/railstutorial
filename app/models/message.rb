class Message < ApplicationRecord
  belongs_to :sender,    class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :content, presence: true, length: {maximum: 1000}
  default_scope -> { order(created_at: :asc) }
end
