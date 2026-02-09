import { Controller } from "@hotwired/stimulus"

class FlashController extends Controller {
  static values = { dismissAfter: { type: Number, default: 5000 } }

  connect() {
    this.timeoutId = setTimeout(() => this.dismiss(), this.dismissAfterValue)
    this.boundDismiss = this.dismiss.bind(this)
    this.element.addEventListener("click", this.boundDismiss)
  }

  disconnect() {
    if (this.timeoutId) clearTimeout(this.timeoutId)
    this.element.removeEventListener("click", this.boundDismiss)
  }

  dismiss() {
    if (this.timeoutId) clearTimeout(this.timeoutId)
    this.element.style.display = "none"
  }
}

export { FlashController as default }
