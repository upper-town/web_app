import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.#removeErrorMessages)
  }

  disconnect() {
    this.element.removeEventListener('input', this.#removeErrorMessages)
  }

  #removeErrorMessages(event) {
    if (!(event.target instanceof HTMLElement)) {
      return
    }

    const wrapper = event.target.closest('div.field_with_errors')

    if (wrapper) {
      wrapper.classList.remove('field_with_errors')
      wrapper.querySelectorAll('.invalid-feedback').forEach((elem) => {
        elem.remove()
      })
    }
  }
}
