// Fisco.io - Tests: ConfirmController (Stimulus)
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import ConfirmController from "../../../app/javascript/controllers/confirm_controller.js"

describe("ConfirmController", () => {
  let application
  let container
  let originalConfirm

  beforeEach(() => {
    application = Application.start()
    application.register("confirm", ConfirmController)
    container = document.createElement("div")
    document.body.appendChild(container)
    originalConfirm = window.confirm
  })

  afterEach(() => {
    window.confirm = originalConfirm
    container?.remove()
  })

  it("conecta y llama a window.confirm en submit", () => {
    window.confirm = vi.fn(() => false)
    container.innerHTML = "<form data-controller=\"confirm\" data-confirm=\"¿Seguro?\"><button type=\"submit\">Enviar</button></form>"
    application.load(container)
    const form = container.querySelector("form")
    form.querySelector("button").click()
    expect(window.confirm).toHaveBeenCalledWith("¿Seguro?")
  })

  it("usa messageValue cuando está definido", () => {
    window.confirm = vi.fn(() => true)
    container.innerHTML = "<form data-controller=\"confirm\" data-confirm-message-value=\"Mensaje custom\"><button type=\"submit\">Enviar</button></form>"
    application.load(container)
    const form = container.querySelector("form")
    form.querySelector("button").click()
    expect(window.confirm).toHaveBeenCalledWith("Mensaje custom")
  })
})
