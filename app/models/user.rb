class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  has_many :send_messages,    class_name:  "Message",
                              foreign_key: "sender_id",
                              dependent:   :destroy
  has_many :receive_messages, class_name:  "Message",
                              foreign_key:  "recipient_id",
                              dependent:   :destroy

  has_many :replied_microposts, class_name: "Micropost",
                                foreign_key: "in_reply_to",
                                dependent:   :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token,:reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true,length: {maximum: 50}
  #validates(:email, presence: true,length: {maximum: 255})
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,presence: true,length:{maximum: 255},
                   format:{with: VALID_EMAIL_REGEX},
                   uniqueness: {case_sensitive: false}
  has_secure_password
  validates(:password,presence: true,length:{minimum: 6},allow_nil: true)

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string,cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest,User.digest(remember_token))
  end

  def authenticated?(attribute,token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest,nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("(user_id IN (#{following_ids}) AND in_reply_to IS NULL)
                     OR (user_id IN (#{following_ids}) AND in_reply_to = :user_id)
                     OR user_id = :user_id", user_id: id)
  end

#return user who current_user sent or received message
  def chat_with
    chats =  Message.where(sender_id: self.id).map{|m| m.recipient_id}
    chats += Message.where(recipient_id: self.id).map{|m| m.sender_id}
    chats.uniq!.delete(self.id)
    User.where(id: chats)
  end

#return messages current_user sent or received with other user
  def messages_with(other_user_id)
    Message.where("( sender_id = :user_id AND recipient_id = :other_id )
                   OR ( recipient_id = :user_id AND sender_id = :other_id )",
                   user_id: self.id, other_id: other_user_id)
  end


  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private
    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end