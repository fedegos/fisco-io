// Fisco.io - Tests: FlashController (Stimulus)
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import { Application } from "@hotwired/stimulus"
import FlashController from "../../../app/javascript/controllers/flash_controller.js"

describe("FlashController", () => {
  let application
  let container

  beforeEach(() => {
    vi.useFakeTimers()
    application = Application.start()
    application.register("flash", FlashController)
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    vi.useRealTimers()
    container?.remove()
  })

  it("conecta y programa dismiss después de dismissAfterValue ms", () => {
    container.innerHTML = "<div data-controller=\"flash\" data-flash-dismiss-after-value=\"5000\"><p>Mensaje</p></div>"
    application.load(container)
    const el = container.querySelector("[data-controller='flash']")
    expect(el.style.display).not.toBe("none")
    vi.advanceTimersByTime(5000)
    expect(el.style.display).toBe("none")
  })

  it("dismiss al hacer click oculta el elemento", () => {
    container.innerHTML = "<div data-controller=\"flash\"><button type=\"button\">Cerrar</button></div>"
    application.load(container)
    const el = container.querySelector("[data-controller='flash']")
    el.querySelector("button").click()
    expect(el.style.display).toBe("none")
  })
})
