# frozen_string_literal: true

# Fisco.io - Operadores: padrón de objetos (obligaciones), CRUD básico + snapshot_at

require "rails_helper"

RSpec.describe "Operadores / Padrón objetos", type: :request do
  describe "GET snapshot_at" do
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
        current_balance: 0,
        principal_balance: 0,
        interest_balance: 0,
        version: 0
      )
    end

    it "responde 200 con turbo frame cuando no hay eventos (snapshot nil)" do
      get operadores_snapshot_at_padron_objeto_path(obligation_id), params: { up_to_version: 1 }, headers: { "Turbo-Frame" => "snapshot_modal" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-frame")
      expect(response.body).to include("No hay datos hasta este evento")
    end

    it "responde 200 con modal cuando hay eventos" do
      repo = EventStore::Repository.new
      event = Obligations::Events::ObligationOpened.new(
        aggregate_id: obligation_id,
        data: {
          "obligation_id" => obligation_id,
          "primary_subject_id" => subject_id,
          "tax_type" => "inmobiliario",
          "role" => "contribuyente",
          "status" => "open"
        }
      )
      repo.append(obligation_id, Obligations::TaxObligation, event)

      get operadores_snapshot_at_padron_objeto_path(obligation_id), params: { up_to_version: 1 }, headers: { "Turbo-Frame" => "snapshot_modal" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Estado de la obligación hasta este evento")
      expect(response.body).to include(obligation_id)
    end
  end

  describe "GET index" do
    it "responde 200" do
      get operadores_padron_objetos_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    before do
      allow_any_instance_of(Operadores::PadronObjetosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "abre partida y redirige al show cuando los datos son válidos" do
      obligation_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid

      post operadores_padron_objetos_path, params: {
        tax_account_balance: {
          obligation_id: obligation_id,
          subject_id: subject_id,
          tax_type: "inmobiliario",
          role: "contribuyente",
          external_id: ""
        }
      }

      expect(response).to redirect_to(operadores_padron_objeto_path(obligation_id))
      expect(flash[:notice]).to eq("Partida abierta.")
    end
  end

  describe "POST import" do
    before do
      allow_any_instance_of(Operadores::PadronObjetosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "redirige con alerta cuando no se envía archivo" do
      post operadores_padron_objetos_import_path

      expect(response).to redirect_to(operadores_padron_objetos_path)
      expect(flash[:alert]).to eq("Seleccione un archivo JSON.")
    end
  end
end
