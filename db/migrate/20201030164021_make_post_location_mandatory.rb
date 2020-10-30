class MakePostLocationMandatory < ActiveRecord::Migration[6.0]
  def change
    change_column_null :posts, :location, false
  end
end
