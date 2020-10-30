class Post < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments

  def before_update
    edited = true
  end
end
