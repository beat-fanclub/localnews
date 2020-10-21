class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :post, null: false, type: :uuid, foreign_key: true
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.boolean :edited
      t.references :parent, null: true, type: :uuid, foreign_key: { to_table: :comments }

      t.timestamps
    end
  end
end
