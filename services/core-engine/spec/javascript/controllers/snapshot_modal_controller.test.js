// Fisco.io - Tests: SnapshotModalController (Stimulus)
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import SnapshotModalController from "../../../app/javascript/controllers/snapshot_modal_controller.js"

describe("SnapshotModalController", () => {
  let application
  let container

  beforeEach(() => {
    application = Application.start()
    application.register("snapshot-modal", SnapshotModalController)
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    container?.remove()
  })

  it("close vacía el contenido del turbo-frame snapshot_modal", () => {
    container.innerHTML = `
      <div data-controller="snapshot-modal">
        <turbo-frame id="snapshot_modal">
          <p>Contenido del modal</p>
        </turbo-frame>
        <button type="button" data-action="click->snapshot-modal#close">Cerrar</button>
      </div>
    `
    application.load(container)
    const frame = container.querySelector("turbo-frame#snapshot_modal")
    expect(frame.innerHTML).toContain("Contenido del modal")
    const btn = container.querySelector("button")
    btn.click()
    expect(frame.innerHTML).toBe("")
  })

  it("stopPropagation evita que el evento se propague", () => {
    container.innerHTML = `
      <div data-controller="snapshot-modal">
        <div data-action="click->snapshot-modal#stopPropagation">Contenido</div>
      </div>
    `
    application.load(container)
    const inner = container.querySelector("[data-action*='stopPropagation']")
    const ev = new MouseEvent("click", { bubbles: true })
    let reachedParent = false
    inner.addEventListener("click", (e) => e.stopPropagation())
    container.addEventListener("click", () => { reachedParent = true })
    inner.dispatchEvent(ev)
    expect(reachedParent).toBe(false)
  })
})
