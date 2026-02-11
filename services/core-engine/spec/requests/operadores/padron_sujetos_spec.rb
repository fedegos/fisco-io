# frozen_string_literal: true

# Fisco.io - Operadores: padrón de sujetos (CRUD básico + snapshot_at)

require "rails_helper"

RSpec.describe "Operadores / Padrón sujetos", type: :request do
  describe "GET buscar" do
    it "responde JSON con lista de sujetos que coinciden con q" do
      SubjectReadModel.create!(
        subject_id: SecureRandom.uuid,
        legal_name: "Empresa SA",
        tax_id: "20-11111111-1",
        registration_date: Date.current,
        status: "active"
      )

      get operadores_buscar_padron_sujetos_path, params: { q: "11111111" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      data = response.parsed_body
      expect(data).to be_an(Array)
      expect(data.size).to eq(1)
      expect(data.first).to include("subject_id", "tax_id" => "20-11111111-1", "legal_name" => "Empresa SA")
    end

    it "responde array vacío cuando no hay coincidencias" do
      get operadores_buscar_padron_sujetos_path, params: { q: "ningunoexistente999" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end
  end

  describe "GET snapshot_at" do
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

    it "responde 200 con turbo frame cuando no hay eventos (snapshot nil)" do
      get operadores_snapshot_at_padron_sujeto_path(subject_id), params: { up_to_version: 1 }, headers: { "Turbo-Frame" => "snapshot_modal" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-frame")
      expect(response.body).to include("No hay datos hasta este evento")
    end

    it "responde 200 con modal cuando hay eventos" do
      repo = EventStore::Repository.new
      event = Identity::Events::SubjectRegistered.new(
        aggregate_id: subject_id,
        data: {
          "subject_id" => subject_id,
          "tax_id" => "20-11111111-1",
          "legal_name" => "Test SA",
          "status" => "active",
          "registration_date" => Date.current.to_s
        }
      )
      repo.append(subject_id, Identity::Subject.name, event)

      get operadores_snapshot_at_padron_sujeto_path(subject_id), params: { up_to_version: 1 }, headers: { "Turbo-Frame" => "snapshot_modal" }

      expect(response).to have_http_status(:ok)
      # El título actual del modal incluye el contexto de sujeto y solo lectura.
      expect(response.body).to include("Estado del sujeto hasta este evento")
      expect(response.body).to include("Test SA")
    end
  end

  describe "POST create" do
    before do
      allow_any_instance_of(Operadores::PadronSujetosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "renderiza new con errores cuando faltan tax_id o legal_name" do
      post operadores_padron_sujetos_path, params: {
        subject_read_model: {
          tax_id: "",
          legal_name: "",
          trade_name: "ACME"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Razón social y CUIT/CUIL son obligatorios.")
    end

    it "crea sujeto y redirige al índice cuando los datos son válidos" do
      post operadores_padron_sujetos_path, params: {
        subject_read_model: {
          tax_id: "20-22222222-9",
          legal_name: "Nuevo SA",
          trade_name: "Nuevo"
        }
      }

      expect(response).to redirect_to(operadores_padron_sujetos_path)
      expect(flash[:notice]).to eq("Sujeto creado correctamente.")
    end
  end

  describe "PATCH update" do
    let(:subject_id) { SecureRandom.uuid }

    before do
      SubjectReadModel.create!(
        subject_id: subject_id,
        legal_name: "Test SA",
        tax_id: "20-11111111-1",
        registration_date: Date.current,
        status: "active"
      )
      allow_any_instance_of(Operadores::PadronSujetosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "renderiza edit con error cuando legal_name está vacío" do
      patch operadores_update_padron_sujeto_path(subject_id), params: {
        subject_read_model: {
          legal_name: "",
          trade_name: "Nuevo nombre"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Razón social es obligatoria.")
    end

    it "actualiza sujeto y redirige al índice cuando los datos son válidos" do
      allow(Identity::Handlers::UpdateSubjectContactDataHandler)
        .to receive(:new).and_return(double(call: true))

      patch operadores_update_padron_sujeto_path(subject_id), params: {
        subject_read_model: {
          legal_name: "Nuevo SA",
          trade_name: "Nuevo",
          contact_entries: [
            { type: "email", value: "test@example.com" }
          ]
        }
      }

      expect(response).to redirect_to(operadores_padron_sujetos_path)
      expect(flash[:notice]).to eq("Sujeto actualizado.")
    end
  end

  describe "POST import" do
    before do
      allow_any_instance_of(Operadores::PadronSujetosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "redirige con alerta cuando no se envía archivo" do
      post operadores_padron_sujetos_import_path

      expect(response).to redirect_to(operadores_padron_sujetos_path)
      expect(flash[:alert]).to eq("Seleccione un archivo JSON.")
    end
  end
end
