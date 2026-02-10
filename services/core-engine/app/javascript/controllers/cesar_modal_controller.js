import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "form", "title", "content"]

  open(event) {
    const url = event.currentTarget.dataset.url || ""
    const subjectName = event.currentTarget.dataset.subjectName || "este sujeto"
    if (this.hasFormTarget) this.formTarget.action = url
    if (this.hasTitleTarget) this.titleTarget.textContent = `Confirmar cese de ${subjectName}`
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("is-hidden")
      this.overlayTarget.setAttribute("aria-hidden", "false")
    }
  }

  close() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("is-hidden")
      this.overlayTarget.setAttribute("aria-hidden", "true")
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
