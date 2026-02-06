# frozen_string_literal: true

# Fisco.io - API: determinar obligación para un período (motor inmobiliario + liquidaciones por cuota)

module Api
  class DeterminationsController < Api::BaseController
    def create
      obligation_id = params[:obligation_id] || params[:id]
      year = params.require(:year).to_i
      result = DetermineObligationForPeriodService.new.call(obligation_id: obligation_id, year: year)
      render json: result, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end
  end
end
