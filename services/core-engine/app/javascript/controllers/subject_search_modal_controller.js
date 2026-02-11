import { Controller } from "@hotwired/stimulus"

// Modal de búsqueda de sujeto por CUIT, razón social o nombre de fantasía.
// Al seleccionar, rellena un campo oculto subject_id y muestra un bloque de solo lectura con los datos.
export default class extends Controller {
  static values = {
    buscarUrl: String,
    minLength: { type: Number, default: 1 }
  }

  static targets = [
    "overlay",
    "input",
    "results",
    "subjectIdInput",
    "summaryBlock",
    "summaryCuit",
    "summaryRazonSocial",
    "summaryNombreFantasia",
    "openButtonWrapper"
  ]

  connect() {
    this._searchTimeout = null
  }

  open() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("is-hidden")
      this.overlayTarget.setAttribute("aria-hidden", "false")
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
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

  search() {
    clearTimeout(this._searchTimeout)
    const q = this.hasInputTarget ? this.inputTarget.value.trim() : ""
    if (q.length < this.minLengthValue) {
      if (this.hasResultsTarget) this.resultsTarget.innerHTML = q.length > 0 ? "<p class=\"form-field__hint\">Escriba al menos " + this.minLengthValue + " carácter(es).</p>" : ""
      return
    }
    this._searchTimeout = setTimeout(() => this._fetch(q), 250)
  }

  async _fetch(q) {
    const url = new URL(this.buscarUrlValue, window.location.origin)
    url.searchParams.set("q", q)
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = "<p class=\"form-field__hint\">Buscando…</p>"
    }
    try {
      const resp = await fetch(url.toString(), { headers: { "Accept": "application/json" } })
      const data = await resp.json()
      this._renderResults(Array.isArray(data) ? data : [])
    } catch (e) {
      if (this.hasResultsTarget) {
        this.resultsTarget.innerHTML = "<p class=\"form-field__hint\" role=\"alert\">Error al buscar. Intente de nuevo.</p>"
      }
    }
  }

  _renderResults(items) {
    if (!this.hasResultsTarget) return
    if (items.length === 0) {
      this.resultsTarget.innerHTML = "<p class=\"form-field__hint\">No se encontraron sujetos.</p>"
      return
    }
    const ul = document.createElement("ul")
    ul.className = "subject-search-results list-unstyled"
    ul.setAttribute("role", "listbox")
    items.forEach((s) => {
      const li = document.createElement("li")
      li.className = "subject-search-results__item"
      li.setAttribute("role", "option")
      li.dataset.subjectId = s.subject_id
      li.dataset.taxId = s.tax_id || ""
      li.dataset.legalName = s.legal_name || ""
      li.dataset.tradeName = s.trade_name || ""
      li.textContent = [s.tax_id, s.legal_name, s.trade_name].filter(Boolean).join(" — ")
      li.addEventListener("click", () => this._select(s))
      ul.appendChild(li)
    })
    this.resultsTarget.innerHTML = ""
    this.resultsTarget.appendChild(ul)
  }

  _select(subject) {
    if (this.hasSubjectIdInputTarget) {
      this.subjectIdInputTarget.value = subject.subject_id
    }
    if (this.hasSummaryCuitTarget) this.summaryCuitTarget.textContent = subject.tax_id || "—"
    if (this.hasSummaryRazonSocialTarget) this.summaryRazonSocialTarget.textContent = subject.legal_name || "—"
    if (this.hasSummaryNombreFantasiaTarget) this.summaryNombreFantasiaTarget.textContent = subject.trade_name || "—"
    if (this.hasSummaryBlockTarget) this.summaryBlockTarget.classList.remove("is-hidden")
    if (this.hasOpenButtonWrapperTarget) this.openButtonWrapperTarget.classList.add("is-hidden")
    this.close()
  }

  clearSelection() {
    if (this.hasSubjectIdInputTarget) this.subjectIdInputTarget.value = ""
    if (this.hasSummaryCuitTarget) this.summaryCuitTarget.textContent = ""
    if (this.hasSummaryRazonSocialTarget) this.summaryRazonSocialTarget.textContent = ""
    if (this.hasSummaryNombreFantasiaTarget) this.summaryNombreFantasiaTarget.textContent = ""
    if (this.hasSummaryBlockTarget) this.summaryBlockTarget.classList.add("is-hidden")
    if (this.hasOpenButtonWrapperTarget) this.openButtonWrapperTarget.classList.remove("is-hidden")
    this.open()
  }
}
