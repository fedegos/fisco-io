# frozen_string_literal: true

# Fisco.io - API: pagos (comando RegisterPayment anidado en obligación)

module Api
  class PaymentsController < Api::BaseController
    def create
      obligation_id = params[:obligation_id] || params[:id]
      cmd = Obligations::Commands::RegisterPayment.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        amount: params.require(:amount).to_d,
        allocations: params[:allocations]
      )
      result = Obligations::Handlers::RegisterPaymentHandler.new.call(cmd)
      render json: {
        obligation_id: result[:obligation_id],
        amount: result[:amount]
      }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end
  end
end