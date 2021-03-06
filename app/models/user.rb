# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }

  validates :username, format: { with: /^[a-zA-Z0-9_\.]*$/, multiline: true }
  # validate :validate_username
  devise :omniauthable, omniauth_providers: %i[facebook google_oauth2]
  attr_writer :login

  has_many :active_relationships, class_name: 'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :posts, dependent: :destroy

  has_many :messages
  has_many :conversations, foreign_key: :sender_id
  has_one_attached :avatar
  default_scope -> { order(created_at: :asc) }
  def login
    @login || username || email
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      conditions[:email]&.downcase!
      where(conditions.to_h).first
    end
  end

  def validate_username
    errors.add(:username, :invalid) if User.where(email: username).exists?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      #user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      user.skip_confirmation!
    end
  end

  #   def self.new_with_session(params, session)
  #     super.tap do |user|
  #       if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
  #         user.email = data["email"] if user.email.blank?
  #       end
  #     end
  #   end

  # mapping string to filed name
  FIELD = { 'name' => :name, 'username' => :username, 'email' => :email }.freeze
  def self.search(data)
    field = FIELD[data[:field]]
    return nil if field.nil?

    value = data[:value]

    users = User.where("LOWER(#{field}) LIKE ?", "%#{value.downcase}%")
    # puts users
    users
  end

  # Follows a user.
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.destroy(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

 
end
