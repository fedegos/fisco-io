# frozen_string_literal: true

# Fisco.io - TaxLiquidationCorrected event
# Liquidación corregida / Liquidation corrected

module Obligations
  module Events
    class TaxLiquidationCorrected < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxLiquidationCorrected",
          data: data,
          **kwargs
        )
      end
    end
  end
end
