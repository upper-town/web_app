import { Controller } from '@hotwired/stimulus'
import '@hotwired/turbo-rails'

export default class extends Controller {
  static targets = ['form']

  connect() {
    this.formTarget.addEventListener('turbo:submit-end', this.#followRedirect)
  }

  #followRedirect(customEvent) {
    const success = customEvent.detail.success
    const response = customEvent.detail.fetchResponse.response

    if (success && response.redirected) {
      Turbo.visit(response.url)
    }
  }
}
