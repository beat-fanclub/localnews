class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :omniauthable, :confirmable, :timeoutable

  has_many :posts
  has_many :comments
  has_many :votes
  has_many :voted_posts, through: :votes, source: :voteable, source_type: :Post
  has_many :voted_comments, through: :votes, source: :voteable, source_type: :Comment
end
