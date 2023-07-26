import { Controller } from '@hotwired/stimulus'
import '@hotwired/turbo-rails'

export default class extends Controller {
  #eventName = 'turbo:submit-end'

  connect() {
    this.element.addEventListener(this.#eventName, this.#followRedirect)
  }

  disconnect() {
    this.element.removeEventListener(this.#eventName, this.#followRedirect)
  }

  #followRedirect(customEvent) {
    const success = customEvent.detail.success
    const response = customEvent.detail.fetchResponse.response

    if (success && response.redirected) {
      Turbo.visit(response.url)
    }
  }
}
