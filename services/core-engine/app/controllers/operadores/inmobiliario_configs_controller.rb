# frozen_string_literal: true

# Fisco.io - Portal operadores: configuración determinación inmobiliario (año, fórmula, cuotas)

module Operadores
  class InmobiliarioConfigsController < ApplicationController
    def index
      @configs = InmobiliarioDeterminationConfig.order(year: :desc)
    end

    def new
      @config = InmobiliarioDeterminationConfig.new(tax_type: "inmobiliario", year: Date.current.year, installments_per_year: 4)
    end

    def create
      @config = InmobiliarioDeterminationConfig.new(config_params)
      if @config.save
        redirect_to operadores_inmobiliario_configs_path, notice: "Configuración creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @config = InmobiliarioDeterminationConfig.find(params[:id])
    end

    def update
      @config = InmobiliarioDeterminationConfig.find(params[:id])
      if @config.update(config_params)
        redirect_to operadores_inmobiliario_configs_path, notice: "Configuración actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def config_params
      params.require(:inmobiliario_determination_config).permit(:tax_type, :year, :formula_base_expression, :installments_per_year)
    end
  end
end
