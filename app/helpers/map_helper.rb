require 'point'

module MapHelper

  def render_map(markers, center=nil, new_point=nil, bounds_reflex=nil)
    center ||= nil
    center = center&.as_leaflet&.to_json unless center == true
    tag.div(
      id: :map,
      class: %w(map),
      data: {
        controller: :map,
        map_center: center,
        map_markers: markers&.to_json,
        map_new_point: new_point,
        map_bounds_reflex: bounds_reflex,
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

    render_map markers, point, new_point, &block
  end

  def marked_map(posts, markers, bounds_reflex, &render_content)
    markers = posts.zip(markers).map do | object, marker |
      marker[:content] = capture do
        yield object
      end
      marker[:location] = marker[:location].as_leaflet
      marker
    end

    render_map(markers, !@stimulus_reflex, nil, bounds_reflex)
  end

end

