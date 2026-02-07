# frozen_string_literal: true

# Fisco.io - TaxObligationUpdated event
# Datos de la obligación actualizados (ej. external_id) / Obligation data updated

module Obligations
  module Events
    class TaxObligationUpdated < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxObligationUpdated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
