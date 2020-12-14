require 'rails_helper'

RSpec.describe Vote, type: :model do

  context 'when changing vote direction' do
    fixtures :posts, :users

    it 'should correctly update the vote sum' do
     voteable = posts(:alice)
      bob = users(:bob)
      bob.vote(voteable, :up)
      expect(voteable.votes_sum).to eq 1
      bob.vote(voteable, :down)
      voteable.reload
      expect(voteable.votes_sum).to eq -1
    end
  end
end
