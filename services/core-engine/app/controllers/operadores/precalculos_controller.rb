# frozen_string_literal: true

# Fisco.io - Portal operadores: precálculo inmobiliario por año
# Generar, validar, revertir o pasar a producción.

module Operadores
  class PrecalculosController < ApplicationController
    def index
      @years_with_preview = DeterminationPreview.distinct.pluck(:year).sort.reverse
    end

    def show
      @year = params[:year].to_i
      @previews = DeterminationPreview.for_year(@year)
    end

    def generar
      year = params[:year].to_i
      if year < 2000
        redirect_to operadores_precalculos_path, alert: "Año inválido."
        return
      end
      result = InmobiliarioPrecalculationService.new.call(year: year)
      redirect_to operadores_precalculo_year_path(year), notice: "Precálculo generado: #{result[:created]} obligaciones con resultado."
    rescue StandardError => e
      redirect_to operadores_precalculos_path, alert: "Error al generar: #{e.message}"
    end

    def validar
      @year = params[:year].to_i
      previews = DeterminationPreview.for_year(@year).draft_or_validated
      errors = []
      previews.each do |p|
        total = p.annual_total
        errors << "Obligación #{p.obligation_id}: total negativo" if total.negative?
      end
      if errors.any?
        redirect_to operadores_precalculo_year_path(@year), alert: "Validación con errores: #{errors.join('; ')}"
      else
        previews.update_all(status: "validated")
        redirect_to operadores_precalculo_year_path(@year), notice: "Precálculo validado correctamente."
      end
    end

    def revertir
      @year = params[:year].to_i
      DeterminationPreview.where(year: @year).delete_all
      redirect_to operadores_precalculos_path, notice: "Precálculo del año #{@year} revertido."
    end

    def producir
      @year = params[:year].to_i
      handler = Obligations::Handlers::CreateLiquidationHandler.new
      count = 0
      DeterminationPreview.for_year(@year).draft_or_validated.find_each do |p|
        Array(p.payload).each do |item|
          period = item["period"] || item[:period]
          amount = (item["amount"] || item[:amount]).to_d
          next if period.blank? || amount.zero?
          cmd = Obligations::Commands::CreateLiquidation.new(
            aggregate_id: p.obligation_id,
            obligation_id: p.obligation_id,
            period: period,
            amount: amount
          )
          handler.call(cmd)
          count += 1
        end
        p.update!(status: "committed")
      end
      redirect_to operadores_precalculo_year_path(@year), notice: "Precálculo pasado a producción: #{count} liquidaciones creadas."
    rescue StandardError => e
      redirect_to operadores_precalculo_year_path(@year), alert: "Error al producir: #{e.message}"
    end
  end
end
