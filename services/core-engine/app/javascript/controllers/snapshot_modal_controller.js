import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    const frame = this.element.querySelector?.("turbo-frame#snapshot_modal") ?? this.element.closest?.("turbo-frame#snapshot_modal")
    if (frame) frame.innerHTML = ""
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
