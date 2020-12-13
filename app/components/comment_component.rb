class CommentComponent < ViewComponentReflex::Component
  delegate :can?, :cannot?, to: :helpers
  attr_reader :current_user

  def initialize(comment:, user:, reactable: true, open: false)
    @comment = comment
    @reactable = reactable
    @open = open
    @current_user = user
  end

  def collection_key
    @comment.id
  end
end
