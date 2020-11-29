module Voteable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :voteable
    has_many :votees, through: :votes, source: :user, inverse_of: "voted_#{table_name}"
  end

  def score
    votes.count
  end

  def vote(user)
    votees << user
  end
end
