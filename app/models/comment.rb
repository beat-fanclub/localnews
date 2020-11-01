class Comment < ApplicationRecord
  include CableReady::Broadcaster

  belongs_to :post
  belongs_to :user
  has_many :children, class_name: "Comment", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Comment", optional: true

  scope :toplevel, -> { where(parent: nil) }

  validate :same_post_as_parent

  after_create :broadcast

  def toplevel?
    parent.nil?
  end

  private

  def broadcast
    html = ApplicationController.render(
      partial: "posts/comment",
      locals: { comment: self }
    )
    cable.insert_adjacent_html(
      selector: "#comments",
      position: "afterend",
      html: html
    )
    cable_ready.broadcast
  end


  def cable
    cable_ready["post_#{post.id}"]
  end

  def same_post_as_parent
    if parent.present? && parent.post != post
      errors.add :post, "is different than the parent comment"
    end
  end
end
