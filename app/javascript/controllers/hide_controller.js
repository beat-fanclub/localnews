import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = [ "whenJS" ];

  connect() {
    super.connect()

    for (const target of this.whenJSTargets) {
      target.style.display = "none"
    }
  }
}
