class AddIndexToPosts < ActiveRecord::Migration[6.0]
  def change
    Rails.configuration.search_languages.each do |lang|
      add_index :posts, "to_tsvector('#{lang}', title || ' ' || content)",
        using: :gin, name: "posts_search_idx_#{lang}"
    end
  end
end
