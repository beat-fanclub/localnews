require "open-uri"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :omniauthable, :confirmable, :timeoutable,
    omniauth_providers: %i[facebook]

  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
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
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    user.external = true
    user.email = auth.info.email
    user.password = Devise.friendly_token[0, 20]
    user.name = auth.info.name   # assuming the user model has a name
    begin
      url = URI.parse(auth.info.image)
      url.scheme = "https"
      filename = "#{auth.provider}--#{File.basename(url.path)}"
      file = URI.open(url.to_s)
      user.avatar.attach(io: file, filename: filename)
    rescue Exception => e
      logger.warn "Couldn't attach image to user: #{e.message}"
    end
    user.skip_confirmation!
    user.save!
    user
  end

end
