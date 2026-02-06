# frozen_string_literal: true

# Fisco.io - Portal contribuyente: listado de obligaciones
# Lee de proyección tax_account_balances (por subject_id de sesión)

module Contribuyente
  class ObligacionesController < ApplicationController
    def index
      # Por ahora sin sesión: listado vacío; luego filtrar por current_subject_id
      @obligaciones = TaxAccountBalance.all
    end
  end
end
