module Voteable
  extend ActiveSupport::Concern

  included do
    define_singleton_method :add_voteable_action do |voteable_name|
      api :POST, "/#{voteable_name}/:id/vote", "vote on #{voteable_name}"
      param :direction, ["up", "down", "none", +1, -1, 0]

      self.define_method :vote do
        dir = params[:direction] || :up
        respond_to do |format|
          if dir.in? ["none", 0]
            success = current_user&.unvote(voteable)
          else
            success = current_user&.vote(voteable, dir)
          end

          if success
            format.html { redirect_to url_for(voteable), notice: 'Vote is registered'}
            format.json { render :show, status: :created, location: self }
          else
            format.html { redirect_to url_for(voteable), "Can't register vote" }
            format.json { render json: voteable.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

end
