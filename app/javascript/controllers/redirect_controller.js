import ApplicationController from './application_controller'

export default class extends ApplicationController {

  redirect(event) {
    Turbolinks.visit(event.detail.to)
  }
}
