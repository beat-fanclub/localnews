import ApplicationController from './application_controller'
import * as L from 'leaflet';

import MarkerIcon from   'leaflet/dist/images/marker-icon.png'
import MarkerIcon2X from 'leaflet/dist/images/marker-icon-2x.png'
import MarkerShadow from 'leaflet/dist/images/marker-shadow.png'

let mapInstance = false

export default class extends ApplicationController {
  static targets = ["container"]

  connect() {
    super.connect()
    this.initLeaflet()
    mapInstance = this
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

    // Set map position
    let data = this.data
    if (data.has("lat") && data.has("lon")) {
      const latlon = ["lat", "lon"].map((key) => data.get(key))
      map.setView(latlon, 13)
      L.marker(latlon).addTo(map)
    } else {
      map.locate({ setView: true})
    }

    this.map = map
  }
}

export { mapInstance }

