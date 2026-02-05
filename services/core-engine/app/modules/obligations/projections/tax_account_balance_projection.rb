# frozen_string_literal: true

# Fisco.io - TaxAccountBalance projection
# Proyección de saldos por obligación (read model) / Obligation balance projection

module Obligations
  module Projections
    class TaxAccountBalanceProjection < BaseProjection
      def handle_TaxObligationCreated(event)
        return unless TaxAccountBalance.table_exists?

        data = event.data
        record = TaxAccountBalance.find_or_initialize_by(obligation_id: data["obligation_id"])
        return if record.persisted? # idempotencia

        record.assign_attributes(
          subject_id: data["primary_subject_id"],
          tax_type: data["tax_type"],
          current_balance: 0,
          principal_balance: 0,
          interest_balance: 0,
          version: 1
        )
        record.save!
      end

      def handle_TaxLiquidationCreated(event)
        return unless TaxAccountBalance.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        amount = BigDecimal(data["amount"].to_s)
        return if amount.zero?

        record = TaxAccountBalance.find_by!(obligation_id: obligation_id)
        record.update!(
          principal_balance: record.principal_balance + amount,
          current_balance: record.current_balance + amount,
          last_liquidation_date: parse_date(data["period"]),
          version: record.version + 1
        )
      end

      def handle_PaymentReceived(event)
        return unless TaxAccountBalance.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        amount = BigDecimal(data["amount"].to_s)

        record = TaxAccountBalance.find_by!(obligation_id: obligation_id)
        record.update!(
          current_balance: record.current_balance - amount,
          last_payment_date: Date.current,
          version: record.version + 1
        )
      end

      def handle_PaymentAppliedToDebt(_event)
        # TODO: actualizar saldos por debt_id
      end

      def handle_InterestAccrued(_event)
        # TODO: actualizar interest_balance
      end

      private

      def parse_date(value)
        return nil if value.blank?
        return value if value.is_a?(Date)
        Date.parse(value.to_s)
      rescue ArgumentError
        nil
      end
    end
  end
end
