class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :omniauthable, :confirmable, :timeoutable,
    omniauth_providers: %i[facebook]

  has_one_attached :avatar
  has_many :posts
  has_many :comments
  has_many :votes
  has_many :voted_posts, through: :votes, source: :voteable, source_type: :Post
  has_many :voted_comments, through: :votes, source: :voteable, source_type: :Comment

  def vote(voteable, direction)
    votes.create_or_find_by(voteable: voteable).update(direction: direction)
  end

  def unvote(voteable)
    votes.delete_by(voteable: voteable)
  end

  def voted?(voteable)
    votes.find_by(voteable: voteable)
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_by!(provider: auth.provider, uid: auth.uid)
    user.email = auth.info.email
    user.password = Devise.friendly_token[0, 20]
    user.name = auth.info.name   # assuming the user model has a name
    user.avatar = auth.info.image # assuming the user model has an image
    # If you are using confirmable and the provider(s) you use validate emails,
    # uncomment the line below to skip the confirmation emails.
    user.skip_confirmation!
  end

end
