# frozen_string_literal: true

# Fisco.io - Pruebas de sistema: flujo padrón de sujetos (navegación y CSS)

require "rails_helper"

RSpec.describe "Operadores / Padrón sujetos (flujo)", type: :system do
  describe "listado vacío" do
    it "muestra la tabla, clases CSS y enlace Empadronar" do
      visit operadores_padron_sujetos_path

      expect(page).to have_css(".page-container")
      expect(page).to have_css(".page-title", text: "Padrón de sujetos")
      expect(page).to have_css(".table-wrapper table.table")
      expect(page).to have_content("Sin sujetos.")
      expect(page).to have_link("Empadronar", href: operadores_new_padron_sujeto_path)
      expect(page).to have_css(".btn.btn--primary")
    end
  end

  describe "flujo listado → detalle → volver" do
    let(:subject_id) { SecureRandom.uuid }

    before do
      SubjectReadModel.create!(
        subject_id: subject_id,
        legal_name: "Test SA",
        tax_id: "20-11111111-1",
        registration_date: Date.current,
        status: "active"
      )
    end

    it "navega al detalle y vuelve al listado, con clases CSS en cada pantalla" do
      visit operadores_padron_sujetos_path

      expect(page).to have_css(".table")
      expect(page).to have_css(".cell-tax-id", text: "20-11111111-1")
      expect(page).to have_content("Test SA")

      click_link "Ver", href: operadores_padron_sujeto_path(subject_id)

      expect(page).to have_current_path(operadores_padron_sujeto_path(subject_id))
      expect(page).to have_css(".page-container")
      expect(page).to have_css(".page-title", text: "Test SA")
      expect(page).to have_css(".card")
      expect(page).to have_content("Identidad")
      expect(page).to have_content("20-11111111-1")

      click_link "Padrón de sujetos"

      expect(page).to have_current_path(operadores_padron_sujetos_path)
      expect(page).to have_css(".table")
      expect(page).to have_content("Test SA")
    end
  end
end
