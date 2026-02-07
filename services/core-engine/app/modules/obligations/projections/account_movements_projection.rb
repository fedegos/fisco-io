# frozen_string_literal: true

# Fisco.io - Account movements projection (cuenta corriente)
# Proyección de movimientos por obligación (débitos y créditos)

module Obligations
  module Projections
    class AccountMovementsProjection < BaseProjection
      def handle_TaxLiquidationCreated(event)
        return unless AccountMovement.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        amount = BigDecimal(data["amount"].to_s)
        return if amount.zero?

        AccountMovement.create!(
          obligation_id: obligation_id,
          movement_type: "liquidation",
          amount: amount,
          debit_credit: "debit",
          movement_date: parse_date(data["period"]) || Date.current,
          period: data["period"].to_s.presence
        )
      end

      def handle_PaymentReceived(event)
        return unless AccountMovement.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        amount = BigDecimal(data["amount"].to_s)
        return if amount.zero?

        AccountMovement.create!(
          obligation_id: obligation_id,
          movement_type: "payment",
          amount: amount,
          debit_credit: "credit",
          movement_date: parse_date(data["paid_at"]) || Date.current,
          reference: data["reference"].to_s.presence
        )
      end

      def handle_InterestAccrued(event)
        return unless AccountMovement.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        amount = BigDecimal((data["amount"] || data["interest_amount"] || 0).to_s)
        return if amount.zero?

        AccountMovement.create!(
          obligation_id: obligation_id,
          movement_type: "interest",
          amount: amount,
          debit_credit: "debit",
          movement_date: parse_date(data["accrued_at"] || data["period"]) || Date.current,
          period: data["period"].to_s.presence
        )
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
