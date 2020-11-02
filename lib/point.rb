module RGeo::Feature::Point

  def lonlat
    [lon, lat]
  end

  def latlon
    lonlat.reverse
  end

  ## Returns the point as a lon, lat dictionary for use with leaflet
  def as_leaflet
    {
      lon: lon,
      lat: lat
    }.as_json
  end
end
