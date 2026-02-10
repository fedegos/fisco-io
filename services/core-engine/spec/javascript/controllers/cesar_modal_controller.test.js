// Fisco.io - Tests: CesarModalController (Stimulus)
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import CesarModalController from "../../../app/javascript/controllers/cesar_modal_controller.js"

describe("CesarModalController", () => {
  let application
  let container

  beforeEach(() => {
    application = Application.start()
    application.register("cesar-modal", CesarModalController)
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    container?.remove()
  })

  it("open actualiza action del form, título y muestra overlay", () => {
    container.innerHTML = `
      <div data-controller="cesar-modal">
        <button type="button" data-action="click->cesar-modal#open" data-url="/sujetos/123/cesar" data-subject-name="ACME SA">Cesar</button>
        <div data-cesar-modal-target="overlay" class="is-hidden" aria-hidden="true">
          <h2 data-cesar-modal-target="title">Título</h2>
          <form data-cesar-modal-target="form" action="">Form</form>
        </div>
      </div>
    `
    application.load(container)
    const overlay = container.querySelector("[data-cesar-modal-target='overlay']")
    const title = container.querySelector("[data-cesar-modal-target='title']")
    const form = container.querySelector("[data-cesar-modal-target='form']")
    expect(overlay.classList.contains("is-hidden")).toBe(true)
    const btn = container.querySelector("button")
    btn.click()
    expect(form.action).toMatch(/\/sujetos\/123\/cesar/)
    expect(title.textContent).toContain("ACME SA")
    expect(overlay.classList.contains("is-hidden")).toBe(false)
  })

  it("close oculta overlay y setea aria-hidden", () => {
    container.innerHTML = `
      <div data-controller="cesar-modal">
        <div data-cesar-modal-target="overlay" aria-hidden="false">Overlay</div>
        <button type="button" data-action="click->cesar-modal#close">Cerrar</button>
      </div>
    `
    application.load(container)
    const overlay = container.querySelector("[data-cesar-modal-target='overlay']")
    container.querySelector("button").click()
    expect(overlay.classList.contains("is-hidden")).toBe(true)
    expect(overlay.getAttribute("aria-hidden")).toBe("true")
  })
})
