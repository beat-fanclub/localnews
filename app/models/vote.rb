class Vote < ApplicationRecord
  belongs_to :voteable, polymorphic: true
  belongs_to :user
  enum direction: { up: 1, down: -1 }

  validates :direction, inclusion: { in: [ -1, 1, :up, :down, "up", "down" ] }

  after_create do
    voteable.increment! :votes_sum, Vote.directions[self.direction]
  end

  after_update do
    direction_change = previous_changes["direction"]

    if direction_change

      old_direction = Vote.directions[direction_change.first]
      new_direction = Vote.directions[direction_change.second]

      voteable.increment!(:votes_sum, new_direction - old_direction)
    end
  end
end
