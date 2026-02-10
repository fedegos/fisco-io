# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Operadores / Consultas", type: :request do
  describe "GET /operadores/consultas" do
    it "responde 200" do
      get operadores_consultas_path
      expect(response).to have_http_status(:ok)
    end
  end
end
