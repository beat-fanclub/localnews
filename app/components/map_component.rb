class MapComponent < ViewComponent::Base
  def initialize(options)
    data = {}
    options[:map].each do |k, v|
      data[:"map_#{k}"] = v
    end

    @data = {
      controller: :map
    }.merge data
  end

  def call
    helpers.tag.div(id: :map, class: %w(map), data: @data) do
      container = '<div data-target="map.container" data-reflex-permanent></div>'
      container.html_safe.concat content
    end
  end
end
