class MapFormComponent < ViewComponent::Base
  def initialize(point, editable = nil)
    point ||= nil
    @new_point = !point || nil
    @map_options = {
      center: point&.as_leaflet&.to_json || "locate",
      new_point: @new_point
    }
    @point = point
    @editable = editable
  end
end
