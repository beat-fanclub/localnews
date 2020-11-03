# frozen_string_literal: true

class MapReflex < ApplicationReflex

  SQL = <<-SQL
    ST_CoveredBy(location, ST_MakeEnvelope(?, ?, ?, ?, 4326))
  SQL

  def new_bounds(north_east, south_west)
    xs = [ north_east[:lng], south_west[:lng] ].sort
    ys = [ north_east[:lat], south_west[:lat] ].sort

    @posts = Post
      .accessible_by(current_ability)
      .where(SQL, xs.first, ys.first, xs.last, ys.last)
  end

end
