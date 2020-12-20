# frozen_string_literal: true

class VoteReflex < ApplicationReflex

  def voteable
    @voteable ||= element.unsigned[:voteable]
  end

  # Reflexes

  def vote()
    if current_ability.cannot? :vote, voteable
      cable_ready.dispatch_event(
        name: "redirect",
        detail: { to: request.routes.url_helpers.new_user_session_path },
      )
      return
    end
    direction = params[:direction]
    if direction.in? ["up" "down"]
      current_user.vote(voteable, direction)
    else
      current_user.unvote(voteable)
    end
    voteable.reload
    morph "#{dom_id(voteable)}-vote", VoteComponent.new(
      voteable: voteable,
      user: current_user,
    )
  end
end
