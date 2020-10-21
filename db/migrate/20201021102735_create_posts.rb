class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    create_join_table :tags, :posts do |t|
      t.index :tag_id
      t.index :user_id
    end
  end
end
