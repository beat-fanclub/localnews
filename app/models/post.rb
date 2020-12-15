class Post < ApplicationRecord
  include Voteable

  SCORE_QUERY = "(votes_sum / extract(epoch FROM created_at))".freeze

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments
  has_rich_text :body

  validates :location, :title, :user_id, presence: true

  before_save :update_content

  scope :within, -> (north_east, south_west) {
      where(<<-SQL, south_west[:lon], south_west[:lat], north_east[:lon], north_east[:lat])
        ST_MakeEnvelope(?, ?, ?, ?, 4326) ~ location::geometry
      SQL
  }

  scope :search, -> (query,  language = :simple) { where(
      "to_tsvector(?, title || ' ' || content) @@ to_tsquery(?)",
      language, query
    ) }

  scope :with_score, -> { select("#{Post::SCORE_QUERY} AS score") }
  default_scope { with_score.select("*") }
  implicit_order_column = :score

  private

  def update_content
    self.content = body.to_plain_text
  end

end
