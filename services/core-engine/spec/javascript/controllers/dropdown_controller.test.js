// Fisco.io - Tests: DropdownController (Stimulus)
import { describe, it, expect, beforeEach, afterEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import DropdownController from "../../../app/javascript/controllers/dropdown_controller.js"

describe("DropdownController", () => {
  let application
  let container

  beforeEach(() => {
    application = Application.start()
    application.register("dropdown", DropdownController)
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    container?.remove()
  })

  it("close quita el atributo open del details", () => {
    container.innerHTML = "<details data-controller=\"dropdown\" open><summary>Menú</summary><div data-dropdown-target=\"menu\">Contenido</div></details>"
    application.load(container)
    const details = container.querySelector("details")
    expect(details.hasAttribute("open")).toBe(true)
    const controller = application.getControllerForElementAndIdentifier(details, "dropdown")
    controller.close()
    expect(details.hasAttribute("open")).toBe(false)
  })

  it("handleEscape cierra al pulsar Escape", () => {
    container.innerHTML = "<details data-controller=\"dropdown\" open><summary>Menú</summary><div data-dropdown-target=\"menu\">Contenido</div></details>"
    application.load(container)
    const details = container.querySelector("details")
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }))
    expect(details.hasAttribute("open")).toBe(false)
  })
})
