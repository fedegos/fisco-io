# frozen_string_literal: true

# Fisco.io - Pruebas de sistema: flujo configuración inmobiliario (navegación y CSS)

require "rails_helper"

RSpec.describe "Operadores / Configuración inmobiliario (flujo)", type: :system do
  it "muestra la página de configuración con estructura y clases CSS" do
    visit operadores_inmobiliario_configs_path

    expect(page).to have_css(".page-container")
    expect(page).to have_css(".page-title", text: "Configuración inmobiliario")
    expect(page).to have_content("Determinación por año")
    expect(page).to have_link("Nueva configuración (año)", href: operadores_configuracion_inmobiliario_new_path)
    expect(page).to have_link("Precálculo por año", href: operadores_precalculos_path)
    expect(page).to have_css(".btn.btn--primary")
    expect(page).to have_css(".btn.btn--secondary")
  end

  it "desde dashboard lleva a configuración inmobiliario y tiene link a precalculos" do
    visit operadores_root_path
    click_link "Configuración inmobiliario", href: operadores_inmobiliario_configs_path

    expect(page).to have_current_path(operadores_inmobiliario_configs_path)
    expect(page).to have_css(".page-title", text: "Configuración inmobiliario")

    click_link "Precálculo por año"

    expect(page).to have_current_path(operadores_precalculos_path)
    expect(page).to have_css(".page-title", text: "Precálculo inmobiliario por año")
  end
end
