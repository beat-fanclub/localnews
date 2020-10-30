class AddLocationDescriptionToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :location_desc, :string
  end
end
