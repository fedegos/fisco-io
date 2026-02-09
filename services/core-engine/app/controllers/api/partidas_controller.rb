# frozen_string_literal: true

# Fisco.io - API: partidas (operaciones de negocio nombradas)
# Endpoints: abrir, revaluos, cerrar, corregir_fuerza_mayor

module Api
  class PartidasController < Api::BaseController
    before_action :set_partida, only: [:revaluos, :cerrar, :corregir_fuerza_mayor]

    def index
      records = TaxAccountBalance.order(updated_at: :desc)
      records = records.where(tax_type: params[:tax_type]) if params[:tax_type].present?
      render json: records.map { |r| obligation_json(r) }
    end

    def abrir
      obligation_id = params[:obligation_id].presence || SecureRandom.uuid
      cmd = Obligations::Commands::OpenObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: params.require(:primary_subject_id),
        tax_type: params.require(:tax_type),
        role: params[:role].presence || "contribuyente",
        external_id: params[:external_id].presence
      )
      result = Obligations::Handlers::OpenObligationHandler.new.call(cmd)
      render json: { obligation_id: result[:obligation_id] }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    def revaluos
      obligation_id = @partida.obligation_id
      year = params.require(:year).to_i
      value = params.require(:value).to_d
      cmd = Obligations::Commands::RegisterRevaluation.new(
        obligation_id: obligation_id,
        year: year,
        value: value,
        operator_observations: params[:operator_observations].presence
      )
      Obligations::Handlers::RegisterRevaluationHandler.new.call(cmd)
      render json: { obligation_id: obligation_id, year: year, value: value.to_f }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    rescue ActiveRecord::RecordNotFound
      render_error("Partida no encontrada", status: :not_found)
    end

    def cerrar
      cmd = Obligations::Commands::CloseObligation.new(obligation_id: @partida.obligation_id)
      Obligations::Handlers::CloseObligationHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError => e
      render_error(e.message)
    rescue ActiveRecord::RecordNotFound
      render_error("Partida no encontrada", status: :not_found)
    end

    def corregir_fuerza_mayor
      obs = params.require(:operator_observations).to_s.strip
      raise ArgumentError, "operator_observations is required" if obs.blank?

      attrs = params.permit(:external_id).to_h.compact_blank
      cmd = Obligations::Commands::CorrectObligationByForceMajeure.new(
        obligation_id: @partida.obligation_id,
        operator_observations: obs,
        **attrs.symbolize_keys
      )
      Obligations::Handlers::CorrectObligationByForceMajeureHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    private

    def set_partida
      @partida = TaxAccountBalance.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error("Partida no encontrada", status: :not_found)
    end

    def obligation_json(record)
      {
        obligation_id: record.obligation_id,
        external_id: record.external_id,
        subject_id: record.subject_id,
        tax_type: record.tax_type,
        current_balance: record.current_balance.to_f,
        principal_balance: record.principal_balance.to_f,
        interest_balance: record.interest_balance.to_f,
        last_liquidation_date: record.last_liquidation_date&.to_s,
        last_payment_date: record.last_payment_date&.to_s
      }
    end
  end
end
