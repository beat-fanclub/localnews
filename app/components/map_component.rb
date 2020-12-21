class MapComponent < ViewComponent::Base
  def initialize(data)
    data.delete(:map).each do |k, v|
      data[:"map_#{k}"] = v
    end

    @data = {
      controller: :map,
      action: "markeradd->map#addMarker turbolinks:render->map#updateMap #{data.delete(:action)}"
    }.merge data
  end

  def call
    helpers.tag.div(id: :map, class: %w(map), data: @data) do
      container = <<-HTML
        <div
          data-target="map.container"
          data-reflex-permanent
          data-turbolinks-permanent
          id="map-container">
        </div>
      HTML
      container.html_safe.concat content
    end
  end
end
