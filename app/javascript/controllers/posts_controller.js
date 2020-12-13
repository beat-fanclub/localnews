import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = ["filterForm", "map"]

  newBounds(event) {
    const mapBoundsInput = this.filterFormTarget.elements["map_bounds"]
    mapBoundsInput.value = event.target.dataset.mapBounds
    mapBoundsInput.dispatchEvent(new Event("change"))
  }

  afterReflex(element, reflex, error) {
    if (!error) {
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
      history.pushState({}, document.title, url)
    }
  }
}
