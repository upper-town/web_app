import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    this.isRendered = false;
  }

  connect() {
    console.log(">>> captcha_controller.js: connect(): called");

    this.render();
  }

  onload() {
    console.log(">>> captcha_controller.js: onload(): called");

    this.render();
  }

  render() {
    if (window.hcaptcha && !this.isRendered) {
      window.hcaptcha.render(this.element);
      this.isRendered = true;
    } else {
      console.log(
        ">>> captcha_controller.js: render(): did not render",
        window.hcaptcha,
        this.isRendered
      );
    }
  }
}
