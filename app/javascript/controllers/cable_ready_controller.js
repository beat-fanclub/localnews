import CableReady from 'cable_ready'
import consumer from '../channels/consumer'
import ApplicationController from './application_controller'

export default class extends ApplicationController {
  connect() {
    super.connect()
    consumer.subscriptions.create({
      channel: this.data.get("channel"),
      id: this.data.get("id")
    }, {
      received(data) {
        if (data.cableReady) CableReady.perform(data.operations)
      }
    })
  }
}

