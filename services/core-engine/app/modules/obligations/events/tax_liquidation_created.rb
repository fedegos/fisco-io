# frozen_string_literal: true

# Fisco.io - TaxLiquidationCreated event
# Liquidación tributaria creada / Tax liquidation created

module Obligations
  module Events
    class TaxLiquidationCreated < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxLiquidationCreated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
