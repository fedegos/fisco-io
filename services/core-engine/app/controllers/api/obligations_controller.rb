# frozen_string_literal: true

# Fisco.io - API: obligaciones (consulta y comando CreateTaxObligation)

module Api
  class ObligationsController < Api::BaseController
    def index
      records = TaxAccountBalance.order(updated_at: :desc)
      render json: records.map { |r| obligation_json(r) }
    end

    def show
      record = TaxAccountBalance.find_by!(obligation_id: params[:id])
      render json: obligation_json(record)
    end

    def create
      obligation_id = params[:obligation_id].presence || SecureRandom.uuid
      cmd = Obligations::Commands::CreateTaxObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: params.require(:primary_subject_id),
        tax_type: params.require(:tax_type),
        role: params[:role].presence || "contribuyente"
      )
      result = Obligations::Handlers::CreateTaxObligationHandler.new.call(cmd)
      render json: { obligation_id: result[:obligation_id] }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    rescue ActiveRecord::RecordNotFound
      render_error("Obligación no encontrada", status: :not_found)
    end

    private

    def obligation_json(record)
      {
        obligation_id: record.obligation_id,
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
