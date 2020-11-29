class CommentComponent < ViewComponentReflex::Component
  delegate :can?, :cannot?, to: :helpers

  def initialize(comment:, reactable: true, open: false)
    @comment = comment
    @reactable = reactable
    @open = open
  end

  def collection_key
    @comment.id
  end
end
