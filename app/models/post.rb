class Post < ApplicationRecord
  include Voteable

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments

  scope :within, -> (north_east, south_west) {
      where(<<-SQL, south_west[:lon], south_west[:lat], north_east[:lon], north_east[:lat])
        ST_MakeEnvelope(?, ?, ?, ?, 4326) ~ location::geometry
      SQL
  }

  scope :search, -> (query,  language = :simple) { where(
      "to_tsvector(?, title || ' ' || content) @@ to_tsquery(?)",
      language, query
    ) }

  def before_update
    edited = true
  end
end
