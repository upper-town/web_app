import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.#addClassIsInvalid()
    this.element.addEventListener("input", this.#removeInvalidFeedbackAndClassIsInvalid)
  }

  disconnect() {
    this.element.removeEventListener("input", this.#removeInvalidFeedbackAndClassIsInvalid)
  }

  #addClassIsInvalid() {
    this.element
      .querySelectorAll("div.field-with-errors input, div.field-with-errors select, div.field-with-errors textarea")
      .forEach((elem) => {
        elem.classList.add("is-invalid")
      })
  }

  #removeInvalidFeedbackAndClassIsInvalid(event) {
    if (!(event.target instanceof HTMLElement)) {
      return
    }

    const wrapper = event.target.closest("div.field-with-errors")

    if (wrapper) {
      wrapper.querySelectorAll(".invalid-feedback").forEach((elem) => {
        elem.remove()
      })
      wrapper.querySelectorAll("input, select, textarea").forEach((elem) => {
        elem.classList.remove("is-invalid")
      })
      wrapper.classList.remove("field-with-errors")
    }
  }
}
