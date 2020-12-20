class VoteComponent < ViewComponent::Base
  attr_reader :current_user

  def initialize(voteable:, user:)
    @voteable = voteable
    @current_user = user
  end

  def voted?
    current_user&.voted?(@voteable)
  end
end
