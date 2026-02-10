# frozen_string_literal: true

# Fisco.io - Operadores: stream de eventos

require "rails_helper"

RSpec.describe "Operadores / Eventos", type: :request do
  describe "GET index" do
    before do
      EventRecord.create!(
        aggregate_id: SecureRandom.uuid,
        aggregate_type: "Identity::Subject",
        event_type: "SubjectRegistered",
        event_version: 1,
        data: { "subject_id" => SecureRandom.uuid, "tax_id" => "20-00000000-0", "legal_name" => "Demo" },
        metadata: {},
        sequence_number: 1
      )
    end

    it "lista los eventos recientes" do
      get operadores_eventos_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("SubjectRegistered")
    end

    it "filtra por event_type" do
      get operadores_eventos_path, params: { event_type: "SubjectRegistered" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("SubjectRegistered")
    end
  end
end

