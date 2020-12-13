class MarkerComponent < ViewComponent::Base
  def initialize(point, title = nil, editable = nil, id: "", target: "map.marker")
    @data = {
      target: target,
      title: title,
      lat: point&.lat,
      lon: point&.lon,
      popup: content_areas? || nil,
      editable: editable,
      controller: :marker
    }
    @id = id
  end
end
