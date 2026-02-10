// Fisco.io - Tests: BracketsFormController (Stimulus)
import { describe, it, expect, beforeEach } from "vitest"
import { Application } from "@hotwired/stimulus"
import BracketsFormController from "../../../app/javascript/controllers/brackets_form_controller.js"

describe("BracketsFormController", () => {
  let application
  let container

  beforeEach(() => {
    application = Application.start()
    application.register("brackets-form", BracketsFormController)
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    container?.remove()
  })

  it("conecta sin error", () => {
    container.innerHTML = `
      <div data-controller="brackets-form" data-brackets-form-start-index-value="0">
        <table><tbody>
          <tr class="brackets-form__new-row">
            <td><input type="number" name="brackets[brackets_attributes][0][base_from]" value="0" /></td>
            <td class="brackets-form__base-to-value">
              <input type="number" name="brackets[brackets_attributes][0][base_to]" value="100" />
            </td>
          </tr>
        </tbody></table>
        <button data-action="click->brackets-form#addRow">Agregar</button>
      </div>
    `
    const el = container.querySelector("[data-controller='brackets-form']")
    expect(() => application.load(el)).not.toThrow()
    const tbody = el.querySelector("tbody")
    expect(tbody.querySelectorAll("tr.brackets-form__new-row").length).toBe(1)
  })

  it("addRow clona la fila plantilla y renumera índices", () => {
    container.innerHTML = `
      <div data-controller="brackets-form" data-brackets-form-start-index-value="1">
        <table><tbody>
          <tr class="brackets-form__new-row">
            <td><input type="number" name="brackets[brackets_attributes][0][base_from]" /></td>
            <td class="brackets-form__base-to-value"><input type="number" name="brackets[brackets_attributes][0][base_to]" /></td>
          </tr>
        </tbody></table>
        <button data-action="click->brackets-form#addRow">Agregar</button>
      </div>
    `
    const el = container.querySelector("[data-controller='brackets-form']")
    application.load(el)
    const btn = el.querySelector("button")
    btn.click()
    const rows = el.querySelectorAll("tr.brackets-form__new-row")
    expect(rows.length).toBe(2)
    const secondRowInput = rows[1].querySelector('input[name*="[base_from]"]')
    expect(secondRowInput.getAttribute("name")).toMatch(/\[brackets_attributes\]\[1\]/)
  })

  it("toggleTramoFinal oculta input y muestra ∞ cuando se marca", () => {
    container.innerHTML = `
      <div data-controller="brackets-form">
        <table><tbody>
          <tr class="brackets-form__new-row">
            <td class="brackets-form__base-to-value">
              <input type="number" name="brackets[brackets_attributes][0][base_to]" value="200" />
              <span class="brackets-form__infinity brackets-form__infinity--hidden">∞</span>
            </td>
            <td><input type="checkbox" data-action="change->brackets-form#toggleTramoFinal" /></td>
          </tr>
        </tbody></table>
      </div>
    `
    const el = container.querySelector("[data-controller='brackets-form']")
    application.load(el)
    const tr = el.querySelector("tr")
    const baseToInput = tr.querySelector('input[type="number"]')
    const infinitySpan = tr.querySelector(".brackets-form__infinity")
    const checkbox = tr.querySelector('input[type="checkbox"]')
    expect(baseToInput.style.display).not.toBe("none")
    checkbox.checked = true
    checkbox.dispatchEvent(new Event("change", { bubbles: true }))
    expect(baseToInput.style.display).toBe("none")
    expect(infinitySpan.classList.contains("brackets-form__infinity--hidden")).toBe(false)
  })
})
