import { Controller } from '@hotwired/stimulus'
import Navigate from '../lib/navigate'

const TURBO_VISIT = 'turbo_visit'
const TURBO_STREAM = 'turbo_stream'
const NEW_TAB = 'new_tab'

export default class extends Controller {
  static values = {
    url: String,
    mode: { type: String, default: TURBO_VISIT },
  }

  initialize() {
    this.navigate = new Navigate(this.urlValue)
  }

  call() {
    switch (this.modeValue) {
      case TURBO_VISIT:
        this.navigate.visitAsTurbo()
        break
      case TURBO_STREAM:
        this.navigate.fetchAsTurboStream()
        break
      case NEW_TAB:
        this.navigate.openInNewTab()
        break
      default:
        throw 'Invalid mode value for navigate controller'
    }
  }
}
