import ApplicationController from './application_controller'
import * as L from 'leaflet';

import MarkerIcon from   'leaflet/dist/images/marker-icon.png'
import MarkerIcon2X from 'leaflet/dist/images/marker-icon-2x.png'
import MarkerShadow from 'leaflet/dist/images/marker-shadow.png'

export default class extends ApplicationController {
  static targets = ["container", "locationInput"]

  connect() {
    super.connect()
    this.containerTarget.map || this.initLeaflet()
    this.map = this.containerTarget.map
    this.updateMap()
  }

  updateMap() {
    let data = this.data

    // Set markers
    let markers = false
    if (this.data.has("markers")) {
      markers = JSON.parse(this.data.get("markers"))
      this.setMarkers(markers)
    }

    // Set map position
    if (data.has("center")) {
      const center = JSON.parse(data.get("center"))
      if (center === true) {
        this.map.fitBounds(L.latLngBounds(markers.map((marker) => marker.location)))
      } else {
        this.map.setView(center, 13)
      }
    } else {
      this.map.locate({ setView: true})
    }

    // Handle panning/zooming the map
    if (this.data.has("bounds-reflex")) {
      this.map.on("moveend", () => {
        const bounds = this.map.getBounds()

        this.stimulate(this.data.get("bounds-reflex"),
          bounds.getNorthEast(), bounds.getSouthWest()
        )
      })
    }


    // Handle adding new points
    this.createPoint(this.data.has("new-point"))
  }

  setMarkers(markerData) {

    if (!Array.isArray(markerData))
      markerData = [ markerData ]

    // Reset layer with new markers
    const markerLayer = this.getMarkerLayer()
    markerLayer.clearLayers()
    markerData.forEach((marker) => {
      this.addMarker(marker)
    })
  }

  getMarkerLayer() {
    return this.containerTarget.markerLayer ||= L.layerGroup().addTo(this.map)
  }

  addMarker(markerData) {
    let latlon = markerData.location
    const marker = L.marker(latlon, {
      title: markerData.title,
      draggable: markerData.editable,
      autoPan: markerData.editable,
    })

    if (markerData.reflex) {
      marker.on('move', (ev) => {
        this.stimulate(
          markerData.reflex, undefined, undefined,
          ev.latlng, markerData.params
        )
      })
    }

    if (this.hasLocationInputTarget) {
      this.setInput(latlon)
      marker.on('move', (ev) => {
        this.setInput(ev.latlng)
      })
    }

    if (markerData.content) {
      marker.bindPopup(markerData.content)
    }

    const markerLayer = this.getMarkerLayer()
    markerLayer.addLayer(marker)
  }

  setInput(latlng) {
    const { lng, lat } = latlng
    this.locationInputTarget.value = `POINT(${lng} ${lat})`
  }

  createPoint(enabled, reflex) {
    const container = this.containerTarget
    if (!this.containerTarget.onClickHandler) {
      this.containerTarget.onClickHandler = () => {;}
      this.map.on('click', (ev) => container.onClickHandler(ev))
    }

    if (enabled) {
      container.onClickHandler = (ev) => {
        container.onClickHandler = () => {;}
        this.addMarker({
          location: ev.latlng,
          editable: true,
          reflex: reflex,
        })
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

    this.containerTarget.map = map
  }
}

