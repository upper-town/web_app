import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  all() {
    this.element.select()
  }
}
