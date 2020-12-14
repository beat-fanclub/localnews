class AddVotesSumToPostsAndComments < ActiveRecord::Migration[6.0]
  def change
    %i[posts comments].each do |voteable|
      add_column voteable, :votes_sum, :integer, default: 0
      add_index voteable, :votes_sum
    end
  end
end
