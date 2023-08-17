import { Controller } from '@hotwired/stimulus'

const DEFAULT = 'default'

export default class extends Controller {
  static targets = ['element']

  static values = {
    name: { type: String, default: DEFAULT },
    onConnect: Boolean,
  }

  connect() {
    if (this.onConnectValue) {
      this.call()
    }
  }

  call() {
    this.dispatch(this.nameValue, { target: this.elementTarget })
  }
}
