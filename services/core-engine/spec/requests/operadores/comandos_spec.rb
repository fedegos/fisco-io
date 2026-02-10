# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Operadores / Comandos", type: :request do
  describe "GET /operadores/comandos" do
    it "responde 200 y muestra lista de comandos" do
      get operadores_comandos_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RegisterSubject")
      expect(response.body).to include("Identity::Subject")
    end
  end
end
