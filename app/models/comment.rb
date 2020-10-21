class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :subcomments, class_name: "Comment", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Comment", optional: true
end
