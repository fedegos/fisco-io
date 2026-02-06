# frozen_string_literal: true

# Fisco.io - API: liquidaciones (comando CreateLiquidation anidado en obligación)

module Api
  class LiquidationsController < Api::BaseController
    def create
      obligation_id = params[:obligation_id] || params[:id]
      cmd = Obligations::Commands::CreateLiquidation.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        period: params.require(:period),
        amount: params.require(:amount).to_d
      )
      result = Obligations::Handlers::CreateLiquidationHandler.new.call(cmd)
      render json: {
        obligation_id: result[:obligation_id],
        period: result[:period],
        amount: result[:amount]
      }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end
  end
end