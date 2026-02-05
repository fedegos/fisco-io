# frozen_string_literal: true

# Fisco.io - TaxAccountBalance projection
# Proyección de saldos por obligación (read model) / Obligation balance projection
# Handlers vacíos en scaffolding / Empty handlers in scaffolding

module Obligations
  module Projections
    class TaxAccountBalanceProjection < BaseProjection
      def handle_TaxObligationCreated(_event)
        # TODO: insert/update tax_account_balances
      end

      def handle_TaxLiquidationCreated(_event)
        # TODO: actualizar principal_balance, last_liquidation_date
      end

      def handle_PaymentReceived(_event)
        # TODO: actualizar current_balance, last_payment_date
      end

      def handle_PaymentAppliedToDebt(_event)
        # TODO: actualizar saldos por debt_id
      end

      def handle_InterestAccrued(_event)
        # TODO: actualizar interest_balance
      end
    end
  end
end
