class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :slug

      t.timestamps
    end
    add_index :tags, :slug, unique: true
  end
end
