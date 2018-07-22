class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :including_replies, ->(replied_id) { where("in_reply_to = ? OR in_reply_to IS NULL",replied_id)}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate  :picture_size


  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture,"should be less than 5MB")
      end
    end
end
