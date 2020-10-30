class AddLocationToPosts < ActiveRecord::Migration[6.0]
  def change
    change_table :posts do |t|
      t.st_point :location, geographic: true

      t.index :location, using: :gist
    end
  end
end
