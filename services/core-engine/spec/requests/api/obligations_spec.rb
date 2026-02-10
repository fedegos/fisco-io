# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API / Obligations", type: :request do
  describe "GET /api/obligations" do
    it "responde 200 y lista obligaciones en JSON" do
      get api_obligations_path
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe "GET /api/obligations/:id" do
    it "responde 404 cuando la obligación no existe" do
      get api_obligation_path(SecureRandom.uuid)
      expect(response).to have_http_status(:not_found)
    end

    it "responde 200 y devuelve la obligación cuando existe" do
      obl = TaxAccountBalance.create!(
        obligation_id: SecureRandom.uuid,
        subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        current_balance: 0,
        principal_balance: 0,
        interest_balance: 0,
        updated_at: Time.current,
        version: 0
      )
      get api_obligation_path(obl.obligation_id)
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["obligation_id"]).to eq(obl.obligation_id)
      expect(json["tax_type"]).to eq("inmobiliario")
    end
  end

  describe "POST /api/obligations" do
    it "crea obligación y responde 201" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new.call(
        Identity::Commands::RegisterSubject.new(aggregate_id: subject_id, tax_id: "20-11111111-1", legal_name: "API Test")
      )
      post api_obligations_path, params: {
        primary_subject_id: subject_id,
        tax_type: "inmobiliario",
        role: "contribuyente"
      }, as: :json
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to have_key("obligation_id")
    end
  end
end
