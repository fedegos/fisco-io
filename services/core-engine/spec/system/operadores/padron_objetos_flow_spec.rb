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

  describe "formulario Abrir partida" do
    it "muestra la estructura del formulario con búsqueda de sujeto y campos" do
      visit operadores_new_padron_objeto_path

      expect(page).to have_css(".page-container")
      expect(page).to have_css(".page-title", text: "Abrir partida")
      expect(page).to have_css(".card form")

      # Campo oculto para subject_id
      expect(page).to have_field("tax_account_balance[subject_id]", type: :hidden)

      # Botón de búsqueda de sujeto
      expect(page).to have_button("Buscar por CUIT o razón social")

      # Modal de búsqueda (con clase is-hidden, oculto por CSS)
      expect(page).to have_css(".modal-overlay.is-hidden")
      expect(page).to have_css("#subject_search_modal_title", text: "Buscar sujeto")

      # Campos del formulario
      expect(page).to have_select("tax_account_balance[tax_type]", options: %w[inmobiliario ingresos_brutos])
      expect(page).to have_select("tax_account_balance[role]", options: ["Contribuyente", "Apoderado", "Responsable sustituto"])
      expect(page).to have_field("tax_account_balance[external_id]")

      # Acciones
      expect(page).to have_button("Abrir partida")
      expect(page).to have_link("Cancelar", href: operadores_padron_objetos_path)
    end
  end

  describe "flujo completo: Abrir partida" do
    let!(:sujeto) do
      SubjectReadModel.create!(
        subject_id: SecureRandom.uuid,
        legal_name: "Empresa Demo SA",
        trade_name: "Demo",
        tax_id: "30-71234567-9",
        registration_date: Date.current,
        status: "active"
      )
    end

    it "crea una partida seleccionando sujeto y completando el formulario" do
      visit operadores_new_padron_objeto_path

      # Simular selección de sujeto (rack_test no ejecuta JS, rellenamos el hidden field)
      find("input[name='tax_account_balance[subject_id]']", visible: false).set(sujeto.subject_id)

      # Completar formulario
      select "inmobiliario", from: "tax_account_balance[tax_type]"
      select "Contribuyente", from: "tax_account_balance[role]"
      fill_in "tax_account_balance[external_id]", with: "001-00012345"

      click_button "Abrir partida"

      # Verifica redirección al detalle de la partida creada
      expect(page).to have_css(".page-title", text: /Objeto 001-00012345/)
      expect(page).to have_content("Partida abierta.")
      expect(page).to have_content("inmobiliario")
    end

    it "muestra error cuando no se selecciona sujeto" do
      visit operadores_new_padron_objeto_path

      # No seleccionar sujeto (subject_id vacío)
      select "inmobiliario", from: "tax_account_balance[tax_type]"
      click_button "Abrir partida"

      # Debe mostrar error y permanecer en el formulario
      expect(page).to have_content("Sujeto y tipo de impuesto son obligatorios")
      expect(page).to have_css(".page-title", text: "Abrir partida")
    end
  end
end
