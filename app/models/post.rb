class Post < ApplicationRecord
  include Voteable

  SCORE_QUERY = "(votes_sum / extract(epoch FROM created_at))".freeze
  URL_REGEX = /\A(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?\z/i

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments
  has_rich_text :body

  validates :location, :title, :user_id, presence: true
  validates :source, format: { with: URL_REGEX }

  before_save :update_content

  scope :within, -> (north_east, south_west) {
      where(<<-SQL, south_west[:lon], south_west[:lat], north_east[:lon], north_east[:lat])
        ST_MakeEnvelope(?, ?, ?, ?, 4326) ~ location::geometry
      SQL
  }

  scope :search, -> (query,  language = :simple) { where(
      "to_tsvector(?, title || ' ' || content) @@ websearch_to_tsquery(?)",
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
