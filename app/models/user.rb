class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :omniauthable, :confirmable, :timeoutable

  devise :omniauthable, omniauth_providers: %i[facebook]

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

end
