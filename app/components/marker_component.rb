class MarkerComponent < ViewComponent::Base
  def initialize(point, title = nil, editable = nil, target: "map.marker")
    @data = {
      target: target,
      title: title,
      lat: point&.lat,
      lon: point&.lon,
      popup: content_areas? || nil,
      editable: editable,
    }
  end
end
