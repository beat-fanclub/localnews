class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes, id: :uuid do |t|
      t.references :voteable, polymorphic: true, null: false, type: :uuid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :votes, [:voteable_id, :voteable_type, :user_id], unique: true
  end
end
