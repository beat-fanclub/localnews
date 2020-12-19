class AddExternalToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :external, :boolean
  end
end
