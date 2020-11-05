# frozen_string_literal: true

class MapReflex < ApplicationReflex

  def new_bounds
    north_east, south_west = JSON.parse(element.dataset.map_bounds).map do |point|
      { lat: point["lat"], lon: point["lng"] }
    end

    @posts = Post
      .accessible_by(current_ability)
      .within(north_east, south_west)

    @bounds = [ north_east, south_west ]
  end

end
