class Comment < ApplicationRecord
  include CableReady::Broadcaster
  include Voteable

  belongs_to :post
  belongs_to :user
  has_many :children, -> { order created_at: :desc }, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Comment", optional: true

  validates :body, presence: true

  scope :toplevel, -> { where(parent: nil) }

  validate :same_post_as_parent

  implicit_order_column = "created_at DESC"

  def toplevel?
    parent.nil?
  end

  private

  def same_post_as_parent
    if parent.present? && parent.post != post
      errors.add :post, "is different than the parent comment"
    end
  end
end
