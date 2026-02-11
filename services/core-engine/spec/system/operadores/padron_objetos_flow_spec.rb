# frozen_string_literal: true

# Fisco.io - Pruebas de sistema: flujo padrón de objetos (navegación y CSS)

require "rails_helper"

RSpec.describe "Operadores / Padrón objetos (flujo)", type: :system do
  describe "listado vacío" do
    it "muestra la tabla, clases CSS y enlace Abrir partida" do
      visit operadores_padron_objetos_path

      expect(page).to have_css(".page-container")
      expect(page).to have_css(".page-title", text: "Padrón de objetos (partidas)")
      expect(page).to have_css(".table-wrapper table.table")
      expect(page).to have_content("Sin obligaciones.")
      expect(page).to have_link("Abrir partida", href: operadores_new_padron_objeto_path)
      expect(page).to have_css(".btn.btn--primary")
    end
  end

  describe "flujo listado → detalle → volver" do
    let(:obligation_id) { SecureRandom.uuid }
    let(:subject_id) { SecureRandom.uuid }

    before do
      SubjectReadModel.create!(
        subject_id: subject_id,
        legal_name: "Test SA",
        tax_id: "20-11111111-1",
        registration_date: Date.current,
        status: "active"
      )
      TaxAccountBalance.create!(
        obligation_id: obligation_id,
        subject_id: subject_id,
        tax_type: "inmobiliario",
        status: "open",
        external_id: "001-00000001"
      )
    end

    it "navega al detalle y vuelve al listado, con clases CSS en cada pantalla" do
      visit operadores_padron_objetos_path

      expect(page).to have_css(".table")
      expect(page).to have_content("001-00000001")
      expect(page).to have_content("inmobiliario")

      click_link "Ver", href: operadores_padron_objeto_path(obligation_id)

      expect(page).to have_current_path(operadores_padron_objeto_path(obligation_id))
      expect(page).to have_css(".page-container")
      expect(page).to have_css(".page-title", text: /Objeto 001-00000001/)
      expect(page).to have_css(".card")
      expect(page).to have_content("Saldo actual")
      expect(page).to have_content("Revalúos")

      click_link "Padrón de objetos"

      expect(page).to have_current_path(operadores_padron_objetos_path)
      expect(page).to have_css(".table")
      expect(page).to have_content("001-00000001")
    end
  end

end
