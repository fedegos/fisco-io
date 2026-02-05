# frozen_string_literal: true

# Fisco.io - TaxLiquidationCancelled event
# Liquidación cancelada / Liquidation cancelled

module Obligations
  module Events
    class TaxLiquidationCancelled < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxLiquidationCancelled",
          data: data,
          **kwargs
        )
      end
    end
  end
end
