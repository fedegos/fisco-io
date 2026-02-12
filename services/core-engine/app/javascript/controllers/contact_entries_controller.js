// Fisco.io - Controlador Stimulus para líneas de contacto dinámicas
// Permite agregar y quitar filas de datos de contacto (email, teléfono, celular)

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "row"]

  connect() {
    this.index = this.rowTargets.length
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/INDEX/g, this.index)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    this.index++
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-contact-entries-target='row']")
    if (row) {
      row.remove()
    }
  }
}
