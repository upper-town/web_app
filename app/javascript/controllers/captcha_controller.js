import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  initialize() {
    this.isRendered = false
  }

  connect() {
    this.render()
  }

  onload() {
    this.render()
  }

  render() {
    if (window.hcaptcha && !this.isRendered) {
      window.hcaptcha.render(this.element)
      this.isRendered = true
    }
  }
}
