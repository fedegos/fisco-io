# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Operadores / Precalculos", type: :request do
  describe "GET /operadores/configuracion/inmobiliario/precalculo" do
    it "responde 200" do
      get operadores_precalculos_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /operadores/configuracion/inmobiliario/precalculo/:year" do
    it "responde 200 para un año válido" do
      get operadores_precalculo_year_path(2024)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /operadores/configuracion/inmobiliario/precalculo/generar" do
    before do
      allow_any_instance_of(Operadores::PrecalculosController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "redirige a precalculos cuando el año es inválido" do
      post "/operadores/configuracion/inmobiliario/precalculo/generar", params: { year: 1999 }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(operadores_precalculos_path)
    end

    it "redirige al año cuando el año es válido" do
      post "/operadores/configuracion/inmobiliario/precalculo/generar", params: { year: 2024 }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(operadores_precalculo_year_path(2024))
    end
  end
end
