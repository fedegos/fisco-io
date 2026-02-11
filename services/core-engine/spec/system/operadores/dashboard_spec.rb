# frozen_string_literal: true

# Fisco.io - Pruebas de sistema: dashboard operadores (navegación y CSS)

require "rails_helper"

RSpec.describe "Operadores / Dashboard", type: :system do
  it "muestra el panel de operadores con estructura y clases CSS esperadas" do
    visit operadores_root_path

    expect(page).to have_content("Panel de operadores")
    expect(page).to have_content("Administración tributaria y configuración.")
    expect(page).to have_link("Padrón de sujetos", href: operadores_padron_sujetos_path)
    expect(page).to have_link("Padrón de objetos", href: operadores_padron_objetos_path)
    expect(page).to have_link("Configuración inmobiliario", href: operadores_inmobiliario_configs_path)
    expect(page).to have_link("Eventos (almacén de eventos)", href: operadores_eventos_path)
    expect(page).to have_link("Consultas (modelos de lectura)", href: operadores_consultas_path)

    expect(page).to have_css(".page-container")
    expect(page).to have_css(".page-header")
    expect(page).to have_css(".page-title", text: "Panel de operadores")
    expect(page).to have_css(".card")
    expect(page).to have_css(".card-grid")
  end
end
