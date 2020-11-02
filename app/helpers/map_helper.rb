require 'point'

module MapHelper

  def marked_map(markers, center=nil, new_point=nil)
    tag.div(
      id: :map,
      class: %w(map),
      data: {
        controller: :map,
        map_center: center&.as_leaflet.to_json,
        map_markers: markers&.to_json,
        map_new_point: new_point,
      }
    ) do
      map_container = tag.div(data: { target: 'map.container', reflex_permanent: true })
      if block_given?
        yield map_container
      else
        map_container
      end
    end
  end

  def point_map(point, editable = false, &block)
    if point
      markers = [ {
        location: point.as_leaflet,
        editable: editable,
      } ]
    else
      markers = []
    end

    new_point = !point || nil

    marked_map markers, point, new_point, &block
  end

end

