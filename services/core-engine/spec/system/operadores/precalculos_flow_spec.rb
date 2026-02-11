# frozen_string_literal: true

# Fisco.io - Pruebas de sistema: flujo precálculo inmobiliario (navegación y CSS)

require "rails_helper"

RSpec.describe "Operadores / Precálculo inmobiliario (flujo)", type: :system do
  it "muestra la página de precálculo con formulario y clases CSS" do
    visit operadores_precalculos_path

    expect(page).to have_css(".page-container")
    expect(page).to have_css(".page-title", text: "Precálculo inmobiliario por año")
    expect(page).to have_link("Configuración inmobiliario", href: operadores_inmobiliario_configs_path)
    expect(page).to have_css(".card")
    expect(page).to have_content("Generar precálculo")
    expect(page).to have_css("input[name='year']")
    expect(page).to have_button("Generar precálculo")
  end

  it "vuelve a configuración inmobiliario desde el breadcrumb" do
    visit operadores_precalculos_path
    click_link "Configuración inmobiliario"

    expect(page).to have_current_path(operadores_inmobiliario_configs_path)
    expect(page).to have_css(".page-title", text: "Configuración inmobiliario")
  end
end
