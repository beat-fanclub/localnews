class MarkerComponent < ViewComponent::Base
  def initialize(point, title = nil, editable = nil)
    @data = {
      target: "map.marker",
      title: title,
      lat: point.lat,
      lon: point.lon,
      popup: block_given?,
      editable: editable,
    }
  end
end
