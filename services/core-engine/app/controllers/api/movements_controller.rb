# frozen_string_literal: true

# Fisco.io - API: movimientos de cuenta corriente por obligación
# GET /api/obligations/:obligation_id/movements

module Api
  class MovementsController < Api::BaseController
    def index
      obligation_id = params[:obligation_id] || params[:id]
      TaxAccountBalance.find_by!(obligation_id: obligation_id) # ensure obligation exists
      movements = AccountMovement.where(obligation_id: obligation_id).order(movement_date: :asc, created_at: :asc)
      render json: movements.map { |m| movement_json(m) }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Obligación no encontrada" }, status: :not_found
    end

    private

    def movement_json(m)
      {
        id: m.id,
        obligation_id: m.obligation_id,
        movement_type: m.movement_type,
        amount: m.amount.to_f,
        debit_credit: m.debit_credit,
        movement_date: m.movement_date&.to_s,
        period: m.period,
        reference: m.reference
      }
    end
  end
end
