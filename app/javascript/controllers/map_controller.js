import ApplicationController from './application_controller'
import * as L from 'leaflet';
import Search from 'leaflet-search';

import MarkerIcon from   'leaflet/dist/images/marker-icon.png'
import MarkerIcon2X from 'leaflet/dist/images/marker-icon-2x.png'
import MarkerShadow from 'leaflet/dist/images/marker-shadow.png'

export default class extends ApplicationController {
  static targets = ["container", "locationInput", "marker", "markerTemplate"]

  connect() {
    super.connect()
    this.containerTarget.map || this.initLeaflet()
    this.map = this.containerTarget.map
    this.updateMap()
  }

  dispatch(name) {
    this.element.dispatchEvent(new Event(name))
  }

  updateMap() {
    let data = this.data

    // Set markers
    let markers = false
    if (this.hasMarkerTarget) {
      markers = this.markerTargets
      this.setMarkers(markers)
    }

    // Set map position
    if (data.has("center")) {
      const center = data.get("center")

      if (center === "markers" && markers) {
        this.map.fitBounds(
          L.latLngBounds(markers.map((marker) => {
            return { lat: marker.dataset.lat, lon: marker.dataset,lon }
          }))
        )

      } else if (center === "locate" || center === "markers") {
        this.map.locate({ setView: true})

      } else if (center === "bounds") {
        const bounds = JSON.parse(data.get("bounds"))
        this.map.fitBounds(L.latLngBounds(bounds))

      } else {
        this.map.setView(JSON.parse(center), 13)
      }
    }

    // Handle adding new points
    this.createPoint(this.data.has("new-point"))

    // Handle panning/zooming the map
    // Use this once to ignore the first event, as it is fired when loading the map.
    this.map.on("moveend", () => {
      const bounds = this.map.getBounds()
      data.set("bounds", JSON.stringify([ bounds.getNorthEast(), bounds.getSouthWest() ]))

      // If the center is located using the GeoLocation API of the browser, the
      // map bounds can change just before Action Cable is set up. This method
      // will wait until that happens.
      this.isActionCableConnectionOpen()
      this.dispatch("moveend")
    })
  }

  setMarkers(markers) {

    // Reset layer with new markers
    const markerLayer = this.getMarkerLayer()
    markerLayer.clearLayers()
    markers.forEach((marker) => {
      this.addMarker(marker)
    })
  }

  getMarkerLayer() {
    if (!this.containerTarget.markerLayer) 
      this.containerTarget.markerLayer = L.layerGroup().addTo(this.map)

    return this.containerTarget.markerLayer
  }

  addMarker(markerEl) {
    let data = markerEl.dataset
    let latlon = { lat: data.lat, lon: data.lon }
    const marker = L.marker(latlon, {
      title: data.title,
      draggable: data.editable,
      autoPan: data.editable,
    })

    marker.on('moveend', (ev) => {
      const latlng = ev.target.getLatLng()
      markerEl.dataset.lat = latlng.lat
      markerEl.dataset.lon = latlng.lng
      markerEl.dispatchEvent(new Event("moveend"))
      this.setInput(latlng)
    })
    this.setInput(marker.getLatLng())

    if (data.popup)
      marker.bindPopup(markerEl)

    const markerLayer = this.getMarkerLayer()
    markerLayer.addLayer(marker)
  }

  setInput(latlng) {
    if (this.hasLocationInputTarget) {
      const { lng, lat } = latlng
      this.locationInputTarget.value = `POINT(${lng} ${lat})`
    }
  }

  createPoint(enabled) {
    const container = this.containerTarget
    if (!this.containerTarget.onClickHandler) {
      this.containerTarget.onClickHandler = () => {;}
      this.map.on('click', (ev) => container.onClickHandler(ev))
    }

    if (enabled) {
      container.onClickHandler = (ev) => {
        container.onClickHandler = () => {;}

        let markerEl = this.markerTemplateTarget;
        // Set the new location
        markerEl.dataset.lat = ev.latlng.lat
        markerEl.dataset.lon = ev.latlng.lng
        this.addMarker(markerEl)
        this.dispatch("newmarker")
      }
    } else {
      container.onClickHandler = () => {;}
    }
  }

  initLeaflet() {

    {
      L.Icon.Default.imagePath = "/.";

      let options = L.Icon.Default.prototype.options
      options.iconUrl = MarkerIcon
      options.iconRetinaUrl = MarkerIcon2X
      options.shadowUrl = MarkerShadow
    }

    // Create map
    let map = L.map(this.containerTarget)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    }).addTo(map);

    new L.Control.Search({
      url: 'https://nominatim.openstreetmap.org/search?format=json&q={s}',
      jsonpParam: 'json_callback',
      propertyName: 'display_name',
      propertyLoc: ['lat','lon'],
      marker: L.circleMarker([0,0],{radius:30}),
      autoCollapse: true,
      autoType: false,
      minLength: 2
    }).addTo(map)

    this.containerTarget.map = map
  }
}

