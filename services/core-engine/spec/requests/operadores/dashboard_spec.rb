# frozen_string_literal: true

# Fisco.io - Operadores: dashboard inicial

require "rails_helper"

RSpec.describe "Operadores / Dashboard", type: :request do
  describe "GET /operadores" do
    it "responde 200 y muestra el panel de operadores" do
      get operadores_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Panel de operadores")
      expect(response.body).to include("Padrón de sujetos")
      expect(response.body).to include("Padrón de objetos")
    end
  end
end

