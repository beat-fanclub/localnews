class CommentComponent < ViewComponentReflex::Component
  delegate :can?, :cannot?, to: :helpers
  attr_reader :current_user

  def initialize(comment:, user:, reactable: true, open: false)
    @comment = comment
    @reactable = reactable
    @open = open
    @current_user = user
  end

  def render?
    @comment.persisted?
  end

  def collection_key
    @comment.id
  end

  def react()
    @reaction = @comment.children.new(post: @comment.post)
  end

  def cancel_react
    @reaction = nil
  end

  def create_reaction
    @reaction.body = params.dig(:reply, :body)
    @reaction.parent = @comment
    @reaction.user = current_user
    if @reaction.save
      cancel_react
      @open = true
    end
  end

  def remove_comment
    @comment.destroy
  end
end
