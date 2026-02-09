import { Controller } from "@hotwired/stimulus"

class ConfirmController extends Controller {
  static values = { message: String }

  connect() {
    this.boundSubmit = this.confirmSubmit.bind(this)
    this.element.addEventListener("submit", this.boundSubmit)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.boundSubmit)
  }

  confirmSubmit(event) {
    const message = this.messageValue ||
      this.element.getAttribute("data-confirm") ||
      "¿Confirmar?"
    if (!window.confirm(message)) {
      event.preventDefault()
    }
  }
}

export { ConfirmController as default }
