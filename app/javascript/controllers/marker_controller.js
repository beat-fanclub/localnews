import ApplicationController from './application_controller'

export default class extends ApplicationController {
  connect() {
    this.element.dispatchEvent(new CustomEvent("markeradd", {
      bubbles: true,
      detail: { id: this.element.id }
    }))
    this.parent = this.element.parentElement
    this.id = this.element.id
  }
  disconnect() {
    console.log(`Removed div#${this.id}`);
    this.element.dispatchEvent(new CustomEvent("markerdel", {
      bubbles: true,
      detail: { id: this.id }
    }))
  }
}
