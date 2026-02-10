# frozen_string_literal: true

# Fisco.io - Operadores: tramos inmobiliario (index, update_all)

require "rails_helper"

RSpec.describe "Operadores / Inmobiliario brackets", type: :request do
  let(:year) { 2025 }

  describe "GET index" do
    it "responde 200 y asigna @brackets para el año" do
      get operadores_inmobiliario_brackets_path(year)

      expect(response).to have_http_status(:ok)
      # No usamos `assigns` (extraído a gem); verificamos que el HTML renderiza la tabla/forma esperada.
      expect(response.body).to include("configuracion/inmobiliario/#{year}/brackets")
    end
  end

  describe "PATCH update_all" do
    before do
      # En tests de request no tenemos token CSRF; desactivamos la verificación solo para este controlador.
      allow_any_instance_of(Operadores::InmobiliarioBracketsController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "guarda tramos válidos (0–100, 100–∞) y redirige con notice" do
      patch operadores_inmobiliario_brackets_path(year), params: {
        brackets: {
          brackets_attributes: {
            "0" => { id: "", base_from: "0", base_to: "100", rate_pct: "1.5", minimum_amount: "0", position: "0", _destroy: "0", tramo_final: "0" },
            "1" => { id: "", base_from: "100", base_to: "", rate_pct: "2", minimum_amount: "0", position: "1", _destroy: "0", tramo_final: "1" }
          }
        }
      }

      expect(response).to redirect_to(operadores_inmobiliario_brackets_path(year))
      expect(flash[:notice]).to eq("Tramos guardados.")
      expect(InmobiliarioRateBracket.where(tax_type: "inmobiliario", year: year).count).to eq(2)
    end

    it "redirige con alert cuando la cobertura es inválida (primer tramo no desde 0)" do
      patch operadores_inmobiliario_brackets_path(year), params: {
        brackets: {
          brackets_attributes: {
            "0" => { id: "", base_from: "10", base_to: "100", rate_pct: "1.5", minimum_amount: "0", position: "0", _destroy: "0", tramo_final: "0" }
          }
        }
      }

      expect(response).to redirect_to(operadores_inmobiliario_brackets_path(year))
      expect(flash[:alert]).to include("primer tramo debe comenzar en 0")
    end
  end
end
