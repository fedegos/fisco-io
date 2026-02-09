import { Controller } from "@hotwired/stimulus"

const GAP = 4
const PAD = 8

class DropdownController extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundClose = this.close.bind(this)
    this.boundPosition = this.positionMenu.bind(this)
    this.element.addEventListener("toggle", this.boundPosition)
    document.addEventListener("click", this.handleClickOutside.bind(this))
    document.addEventListener("keydown", this.handleEscape.bind(this))
    window.addEventListener("scroll", this.boundClose, true)
    if (this.hasMenuTarget) {
      this.menuTarget.addEventListener("click", this.handleMenuClick.bind(this))
    }
  }

  disconnect() {
    this.element.removeEventListener("toggle", this.boundPosition)
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    document.removeEventListener("keydown", this.handleEscape.bind(this))
    window.removeEventListener("scroll", this.boundClose, true)
    if (this.hasMenuTarget) {
      this.menuTarget.removeEventListener("click", this.handleMenuClick.bind(this))
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  handleEscape(event) {
    if (event.key === "Escape") this.close()
  }

  handleMenuClick(event) {
    if (event.target.closest("a[href]") || event.target.closest("form")) {
      this.close()
    }
  }

  close() {
    this.element.removeAttribute("open")
    if (this.hasMenuTarget) {
      const m = this.menuTarget
      m.style.position = ""
      m.style.top = ""
      m.style.left = ""
      m.style.visibility = ""
      m.style.maxHeight = ""
      m.style.overflowY = ""
    }
  }

  positionMenu() {
    if (!this.element.open || !this.hasMenuTarget) return
    const summary = this.element.querySelector("summary")
    const menu = this.menuTarget
    if (!summary) return
    const rect = summary.getBoundingClientRect()
    requestAnimationFrame(() => {
      const menuH = menu.offsetHeight
      const menuW = menu.offsetWidth
      const vw = window.innerWidth
      const vh = window.innerHeight
      const openBelow = rect.bottom + GAP + menuH <= vh
      let top = openBelow ? rect.bottom + GAP : rect.top - GAP - menuH
      let left = rect.left
      if (left + menuW > vw - PAD) left = vw - menuW - PAD
      if (left < PAD) left = PAD
      if (top < PAD) {
        top = PAD
        menu.style.maxHeight = vh - PAD * 2 + "px"
        menu.style.overflowY = "auto"
      }
      menu.style.top = top + "px"
      menu.style.left = left + "px"
      menu.style.visibility = "visible"
    })
  }
}

export { DropdownController as default }
