import ApplicationController from './application_controller'

import MarkerIcon from 'leaflet/dist/images/marker-icon.png'
import MarkerIcon2X from 'leaflet/dist/images/marker-icon-2x.png'
import MarkerShadow from 'leaflet/dist/images/marker-shadow.png'

export default class extends ApplicationController {
  static targets = ["container", "locationInput", "marker", "markerTemplate"]

  async connect() {
    super.connect()
    this.Lf = await import(/* webpackPrefetch: true */ "leaflet")
    this.LfSearch = await import(/* webpackPrefetch: true */ "leaflet-search")
    const containerTarget = this.containerTarget
    containerTarget.map || this.initLeaflet()
    this.map = containerTarget.map
    if (!containerTarget.markers) this.containerTarget.markers = {}
    this.updateMap()
  }

  dispatch(name) {
    this.element.dispatchEvent(new Event(name))
  }

  updateMap() {
    console.log("Updating map")
    let data = this.data

    // Set markers
    let markers = false
    if (this.hasMarkerTarget) {
      markers = this.markerTargets
      this.setMarkers(markers)
    }

    // Set map position
    console.log("Set map position");
    this.dispatch("before-map-bounds-init")
    const updateNow = true;
    if (data.has("center")) {
      const center = data.get("center")

      if (center === "markers" && markers) {
        this.map.fitBounds(
          this.Lf.latLngBounds(markers.map((marker) => {
            return {lat: marker.dataset.lat, lon: marker.dataset.lon}
          }))
        )

      } else if (center === "locate" || center === "markers") {
        this.map.locate({setView: true, maxZoom: 13})

      } else if (center === "bounds") {
        const bounds = JSON.parse(data.get("bounds"))
        console.log(`Setting bounds ${data.get("bounds")}`);
        this.map.fitBounds(this.Lf.latLngBounds(bounds))
        const updateNow = false;

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
      data.set("bounds", JSON.stringify([bounds.getNorthEast(), bounds.getSouthWest()]))

      // If the center is located using the GeoLocation API of the browser, the
      // map bounds can change just before Action Cable is set up. This method
      // will wait until that happens.
      this.isActionCableConnectionOpen()
      this.dispatch("moveend")
    })

    if (updateNow) {
      this.dispatch("after-map-bounds-init")
    } else {
      this.map.once("moveend", () => {
        this.map.once("movestart", () => {
          this.dispatch("after-map-bounds-init")
          console.log("Done set map position");
        })
      })
    }
  }

  setMarkers(markers) {

    this.containerTarget.markers = {}

    // Reset layer with new markers
    const markerLayer = this.getMarkerLayer()
    markerLayer.clearLayers()
    markers.forEach((marker) => {
      this.addMarkerEl(marker)
    })
  }

  getMarkerLayer() {
    if (!this.containerTarget.markerLayer)
      this.containerTarget.markerLayer = this.Lf.layerGroup().addTo(this.map)

    return this.containerTarget.markerLayer
  }

  addMarker(markerEv) {
    const markerEl = markerEv.target
    const id = markerEl.id
    const markers = this.containerTarget.markers || {}
    markers[id] || this.addMarkerEl(markerEl)
  }

  removeMarker(markerEv) {
    const id = markerEv.detail.id
    // console.log(`Removing marker#${id}`);
    const markers = this.containerTarget.markers
    if (!markers) return
    const marker = markers[id]
    if (!marker) return
    marker.removeFrom(this.getMarkerLayer())
    markers[id] = null
  }

  addMarkerEl(markerEl) {
    let data = markerEl.dataset
    let latlon = {lat: data.lat, lon: data.lon};

    (async () => {
      this.Lf = await import(/* webpackPrefetch: true */ "leaflet")
      const marker = this.Lf.marker(latlon, {
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

      markerEl.addEventListener("markerdel", ev => this.removeMarker(ev))

      if (data.popup)
        marker.bindPopup(markerEl.outerHTML)

      const markerLayer = this.getMarkerLayer()
      markerLayer.addLayer(marker)

      this.containerTarget.markers[markerEl.id] = marker
    })()
  }

  setInput(latlng) {
    if (this.hasLocationInputTarget) {
      const {lng, lat} = latlng
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
        this.addMarkerEl(markerEl)
        this.dispatch("newmarker")
      }
    } else {
      container.onClickHandler = () => {;}
    }
  }

  initLeaflet() {

    {
      this.Lf.Icon.Default.imagePath = "/.";

      let options = this.Lf.Icon.Default.prototype.options
      options.iconUrl = MarkerIcon
      options.iconRetinaUrl = MarkerIcon2X
      options.shadowUrl = MarkerShadow
    }

    // Create map
    let map = this.Lf.map(this.containerTarget)
    this.Lf.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    }).addTo(map);

    new this.Lf.Control.Search({
      url: 'https://nominatim.openstreetmap.org/search?format=json&q={s}',
      jsonpParam: 'json_callback',
      propertyName: 'display_name',
      propertyLoc: ['lat', 'lon'],
      marker: this.Lf.circleMarker([0, 0], {radius: 30}),
      autoCollapse: true,
      autoType: false,
      minLength: 2
    }).addTo(map)

    this.containerTarget.map = map
  }

  cancelMapUpdateLoop(event) {
    const newUrl = new URL(event.data.url)
    const newSearch = new URLSearchParams(newUrl.search)
    const sameBounds = (this.locationInputTarget.value === newSearch.get("map_bounds"))
    const samePath = (document.location.pathname === url.pathname)
    if (!sameBounds && samePath)
      event.preventDefault()
  }
}

