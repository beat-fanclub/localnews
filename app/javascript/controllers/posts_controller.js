import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = ["filterForm", "map"]

  newBounds(event) {
    const mapBoundsInput = this.filterFormTarget.elements["map_bounds"]
    mapBoundsInput.value = event.target.dataset.mapBounds
    mapBoundsInput.dispatchEvent(new Event("change"))
  }

  updateUrl(event) {
    // Base params
    const params = new URLSearchParams(window.location.search)

    // Load all the filters from the form
    Array.prototype.slice.call(this.filterFormTarget.elements)
      .forEach(element => {
        const paramName = element.name
        const paramValue = element.value
        if (paramValue && paramValue.length !== 0)
          params.set(paramName, paramValue)
        else
          params.delete(paramName)
      })

    const queryString = params.toString()
    const query = queryString.length ? '?' : ''
    const url = `${window.location.pathname}${query}${queryString}`
    if (self.navigation) {
      console.log(`Visiting ${url}`);
      // Derived from: https://stackoverflow.com/questions/53173328/manage-browser-history-manually-for-one-part-of-my-turbolinks-enabled-rails-5-ap
      //  Turbolinks
      //    .controller
      //    .pushHistoryWithLocationAndRestorationIdentifier(url, Turbolinks.uuid())

      this.stimulate("Posts#filter", event.currentTarget)
    }
  }

  enableNavigation() {
    self.navigation = true
  }
  disableNavigation() {
    self.navigation = false
  }
}
