# frozen_string_literal: true

# Fisco.io - Portal contribuyente: obligaciones (TDD)
# GET /contribuyente/obligaciones devuelve HTML con listado de obligaciones

require "rails_helper"

RSpec.describe "Contribuyente / Obligaciones", type: :request do
  describe "GET /contribuyente/obligaciones" do
    it "responde 200 y devuelve HTML" do
      get "/contribuyente/obligaciones"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/html")
    end

    it "incluye el título o encabezado de obligaciones" do
      get "/contribuyente/obligaciones"

      expect(response.body).to include("Obligaciones")
    end

    it "incluye la estructura de tabla para listar obligaciones" do
      get "/contribuyente/obligaciones"

      expect(response.body).to match(/<table|<thead|<tbody/)
    end
  end
end
