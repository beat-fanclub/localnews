class IndexScoreOnPosts < ActiveRecord::Migration[6.0]
  def change
    add_index :posts, Post::SCORE_QUERY, name: "posts_score_idx"
  end
end
