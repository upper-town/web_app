import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  filter() {
    this.element.requestSubmit();
  }
}
