# frozen_string_literal: true

# Fisco.io - Operadores: detalle de obligación (cuenta corriente)

require "rails_helper"

RSpec.describe "Operadores / Obligaciones", type: :request do
  describe "GET show" do
    let(:obligation_id) { SecureRandom.uuid }
    let(:subject_id) { SecureRandom.uuid }

    before do
      SubjectReadModel.create!(
        subject_id: subject_id,
        legal_name: "Test SA",
        tax_id: "20-33333333-9",
        registration_date: Date.current,
        status: "active"
      )
      TaxAccountBalance.create!(
        obligation_id: obligation_id,
        subject_id: subject_id,
        tax_type: "inmobiliario",
        status: "open",
        current_balance: 1000,
        principal_balance: 1000,
        interest_balance: 0,
        version: 1
      )
      AccountMovement.create!(
        obligation_id: obligation_id,
        movement_type: "liquidation",
        debit_credit: "debit",
        movement_date: Date.current,
        amount: 1000,
        period: "2024-01"
      )
    end

    it "muestra el detalle de la obligación con movimientos y sujetos responsables" do
      get operadores_obligacion_path(obligation_id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Obligación")
      expect(response.body).to include("Test SA")
      expect(response.body).to include("Movimientos")
      expect(response.body).to include("Liquidación")
    end

    it "redirige a consultas cuando la obligación no existe" do
      get operadores_obligacion_path(SecureRandom.uuid)

      expect(response).to redirect_to(operadores_consultas_path)
      expect(flash[:alert]).to eq("Obligación no encontrada")
    end
  end
end

