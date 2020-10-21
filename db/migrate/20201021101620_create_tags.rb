class CreateTags < ActiveRecord::Migration[6.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
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
