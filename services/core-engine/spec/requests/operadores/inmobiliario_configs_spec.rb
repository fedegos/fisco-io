# frozen_string_literal: true

# Fisco.io - Operadores: configuración determinación inmobiliario

require "rails_helper"

RSpec.describe "Operadores / Inmobiliario configs", type: :request do
  describe "GET index" do
    it "responde 200 y lista configuraciones" do
      InmobiliarioDeterminationConfig.create!(
        tax_type: "inmobiliario",
        year: 2025,
        formula_base_expression: "valuacion * 1.0",
        installments_per_year: 4
      )

      get operadores_inmobiliario_configs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Configuración inmobiliario")
    end
  end

  describe "GET new" do
    it "responde 200 y muestra el formulario" do
      get "/operadores/configuracion/inmobiliario/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nueva configuración")
    end
  end

  describe "POST create" do
    before do
      allow_any_instance_of(Operadores::InmobiliarioConfigsController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "crea configuración válida y redirige al índice" do
      post operadores_inmobiliario_configs_path, params: {
        inmobiliario_determination_config: {
          tax_type: "inmobiliario",
          year: 2025,
          formula_base_expression: "valuacion * 1.0",
          installments_per_year: 4
        }
      }

      expect(response).to redirect_to(operadores_inmobiliario_configs_path)
      expect(flash[:notice]).to eq("Configuración creada.")
      expect(InmobiliarioDeterminationConfig.count).to eq(1)
    end

    it "renderiza new con errores cuando los datos son inválidos" do
      post operadores_inmobiliario_configs_path, params: {
        inmobiliario_determination_config: {
          tax_type: "",
          year: 0,
          formula_base_expression: "",
          installments_per_year: 0
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH update" do
    let!(:config) do
      InmobiliarioDeterminationConfig.create!(
        tax_type: "inmobiliario",
        year: 2025,
        formula_base_expression: "valuacion * 1.0",
        installments_per_year: 4
      )
    end

    before do
      allow_any_instance_of(Operadores::InmobiliarioConfigsController)
        .to receive(:verify_authenticity_token).and_return(true)
    end

    it "actualiza configuración válida y redirige al índice" do
      patch operadores_inmobiliario_config_path(config), params: {
        inmobiliario_determination_config: {
          formula_base_expression: "valuacion * 1.5",
          installments_per_year: 6
        }
      }

      expect(response).to redirect_to(operadores_inmobiliario_configs_path)
      expect(flash[:notice]).to eq("Configuración actualizada.")
      config.reload
      expect(config.formula_base_expression).to eq("valuacion * 1.5")
      expect(config.installments_per_year).to eq(6)
    end

    it "renderiza edit con errores cuando los datos son inválidos" do
      patch operadores_inmobiliario_config_path(config), params: {
        inmobiliario_determination_config: {
          installments_per_year: 0
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

