class CommentComponent < ViewComponentReflex::Component
  delegate :can?, :cannot?, to: :helpers

  def initialize(comment:)
    @comment = comment
  end

  def collection_key
    @comment.id
  end
end
