class Vote < ApplicationRecord
  belongs_to :voteable, polymorphic: true
  belongs_to :user
  enum direction: { up: 1, down: -1 }

  validates :direction, inclusion: { in: [ -1, 1, :up, :down, "up", "down" ] }
end
