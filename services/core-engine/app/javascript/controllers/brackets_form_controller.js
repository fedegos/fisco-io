// Fisco.io - Grilla de tramos: agregar/quitar filas, tramo final (hasta ∞)
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { startIndex: { type: Number, default: 0 } }

  connect() {
    this.renumberNewRows()
  }

  addRow(event) {
    event.preventDefault()
    const tbody = this.element.querySelector("tbody")
    const newRows = tbody.querySelectorAll("tr.brackets-form__new-row")
    const template = newRows[0]
    if (!template) return
    const clone = template.cloneNode(true)
    clone.querySelectorAll("input").forEach((input) => {
      if (input.type === "hidden" && input.name.includes("[id]")) return
      input.value = ""
      input.removeAttribute("value")
    })
    clone.querySelectorAll("input[type=checkbox]").forEach((cb) => { cb.checked = false })
    tbody.appendChild(clone)
    this.renumberNewRows()
  }

  removeRow(event) {
    event.preventDefault()
    const tr = event.target.closest("tr")
    if (!tr) return
    if (tr.classList.contains("brackets-form__new-row")) {
      tr.remove()
      this.renumberNewRows()
      return
    }
    const destroyCb = tr.querySelector('input[name*="[_destroy]"]')
    if (destroyCb) {
      destroyCb.checked = true
      tr.classList.add("brackets-form__row--destroy")
    }
  }

  renumberNewRows() {
    const tbody = this.element.querySelector("tbody")
    const newRows = Array.from(tbody.querySelectorAll("tr.brackets-form__new-row"))
    const start = this.startIndexValue
    newRows.forEach((row, i) => {
      const idx = start + i
      row.querySelectorAll("input, select").forEach((input) => {
        const name = input.getAttribute("name")
        if (!name || !name.includes("[brackets_attributes]")) return
        input.setAttribute("name", name.replace(/\[brackets_attributes\]\[\d+\]/, `[brackets_attributes][${idx}]`))
      })
    })
  }

  toggleTramoFinal(event) {
    const tr = event.target.closest("tr")
    if (!tr) return
    const baseToInput = tr.querySelector('input[name*="[base_to]"]:not([type=hidden])')
    const hidden = tr.querySelector('input[type=hidden][name*="[base_to]"]')
    const tramoFinalCb = event.target
    const name = hidden ? hidden.getAttribute("name") : (baseToInput && baseToInput.getAttribute("name"))
    if (!name) return
    if (tramoFinalCb.checked) {
      if (baseToInput) {
        baseToInput.disabled = true
        const h = document.createElement("input")
        h.type = "hidden"
        h.name = name
        h.value = ""
        baseToInput.parentNode.appendChild(h)
      }
    } else {
      if (baseToInput) {
        baseToInput.disabled = false
        const h = tr.querySelector(`input[type=hidden][name="${name}"]`)
        if (h) h.remove()
      } else if (hidden) {
        const input = document.createElement("input")
        input.type = "number"
        input.name = hidden.getAttribute("name")
        input.min = "0"
        input.step = "0.01"
        input.placeholder = "—"
        input.className = "form-input form-input--number"
        hidden.parentNode.appendChild(input)
        hidden.remove()
      }
    }
  }
}
