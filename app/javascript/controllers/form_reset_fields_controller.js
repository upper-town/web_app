import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { fields: Object }

  call() {
    this.reset()
    this.submit()
  }

  reset() {
    this.element.reset()

    if (this.hasFieldsValue) {
      for (const [fieldId, blankValue] of Object.entries(this.fieldsValue)) {
        const element = document.getElementById(fieldId)

        if (element) {
          element.value = blankValue
        }
      }
    }
  }

  submit() {
    this.element.requestSubmit()
  }
}
