# frozen_string_literal: true

# Fisco.io - API: subjects

require "rails_helper"

RSpec.describe "API /subjects", type: :request do
  describe "GET /api/subjects" do
    before do
      SubjectReadModel.create!(
        subject_id: SecureRandom.uuid,
        legal_name: "Test SA",
        tax_id: "20-44444444-9",
        registration_date: Date.current,
        status: "active"
      )
    end

    it "devuelve lista JSON de sujetos" do
      get api_subjects_path, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include("subject_id", "tax_id", "legal_name")
    end
  end

  describe "POST /api/subjects" do
    it "crea sujeto cuando los parámetros son válidos" do
      post api_subjects_path,
           params: { tax_id: "20-55555555-9", legal_name: "API SA", trade_name: "API" },
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["subject_id"]).to be_present
    end

    it "retorna error cuando faltan parámetros requeridos" do
      post api_subjects_path,
           params: { legal_name: "Sin CUIT" },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]).to be_present
    end
  end
end

