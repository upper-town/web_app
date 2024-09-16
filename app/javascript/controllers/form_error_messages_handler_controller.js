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

    const wrapper = event.target.closest('div.field-with-errors')

    if (wrapper) {
      wrapper.classList.remove('field-with-errors')
      wrapper.querySelectorAll('.invalid-feedback').forEach((elem) => {
        elem.remove()
      })
    }
  }
}
