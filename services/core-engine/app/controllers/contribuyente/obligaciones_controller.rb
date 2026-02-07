# frozen_string_literal: true

# Fisco.io - Portal contribuyente: listado y detalle de obligaciones
# Lee de proyección tax_account_balances (por subject_id de sesión)

module Contribuyente
  class ObligacionesController < ApplicationController
    def index
      # Por ahora sin sesión: listado vacío; luego filtrar por current_subject_id
      @obligaciones = TaxAccountBalance.all
    end

    def show
      @obligacion = TaxAccountBalance.find_by!(obligation_id: params[:id])
      @movimientos = AccountMovement.where(obligation_id: params[:id]).order(movement_date: :asc, created_at: :asc)
    rescue ActiveRecord::RecordNotFound
      redirect_to contribuyente_obligaciones_path, alert: "Obligación no encontrada"
    end
  end
end
