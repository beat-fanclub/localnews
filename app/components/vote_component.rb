class VoteComponent < ViewComponentReflex::Component
  delegate :can?, :cannot?, to: :helpers
  attr_reader :current_user

  def initialize(voteable:, user:)
    @voteable = voteable
    @current_user = user
  end

  def vote(direction)
    current_user.vote(@voteable, direction)
  end

  def upvote
    vote(:up)
  end

  def downvote
    vote(:down)
  end

  def unvote
    current_user.unvote(@voteable)
  end

  def voted?
    current_user.voted?(@voteable)
  end

  def collection_key
    @voteable.id
  end
end
