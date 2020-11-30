class AddDirectionToVotes < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :direction, :integer, null: false, default: 1
  end
end
