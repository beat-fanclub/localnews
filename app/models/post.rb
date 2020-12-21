class Post < ApplicationRecord
  include Voteable

  SCORE_QUERY = "(votes_sum / extract(epoch FROM created_at))".freeze
  URL_REGEX = /\A(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?\z/i

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments, dependent: :destroy
  has_rich_text :body

  validates :location, :title, :user_id, presence: true
  validates :source, format: { with: URL_REGEX }, allow_blank: true

  before_save :update_content
  before_validation do
    scrape_source!(self.source) if body.blank? && source.present?
    update_location!
  end

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

  def scrape_source!(url)
    begin
      page = MetaInspector.new(url)
      self.title = page.best_title if title.blank?
      self.body = page.best_description
      self.source = page.url

      scrape_wikipedia! if page.host.ends_with? "wikipedia.org"
    rescue MetaInspector::TimeoutError, MetaInspector::RequestError, MetaInspector::ParserError, MetaInspector::NonHtmlError => e
      errors.add :source, :scrape_error, message: "isn't scrapeable: #{e.message}"
    end
  end

  private

  def update_content
    self.content = body.to_plain_text
  end

  def update_location!
    if location
      url = URI::parse "https://nominatim.openstreetmap.org/reverse"
      url.query = {
        lat: location.lat,
        lon: location.lon,
        format: :json,
      }.to_param
      res = Net::HTTP.get url
      json = JSON::parse res
      self.location_desc = json["display_name"]
    elsif location_desc
    end
  end

  def scrape_wikipedia!
    url = URI::parse(self.source)
    return unless url.path.start_with? "/wiki/"
    page_title = url.path.delete_prefix "/wiki/"
    url.query = {
      action: :query,
      prop: :coordinates,
      format: :json,
      titles: URI::decode(page_title)
    }.to_param
    url.path = "/w/api.php"
    url.scheme = "https"
    res = Net::HTTP.get url
    json = JSON::parse res
    pages = json.dig("query", "pages")
    return if pages.blank?
    coords = pages.first&.dig(1, "coordinates", 0)
    return unless coords
    self.location = "POINT(#{coords["lon"]} #{coords["lat"]})"
  end

end
