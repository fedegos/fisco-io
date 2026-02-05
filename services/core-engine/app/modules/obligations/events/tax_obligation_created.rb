# frozen_string_literal: true

# Fisco.io - TaxObligationCreated event
# Obligación tributaria creada / Tax obligation created

module Obligations
  module Events
    class TaxObligationCreated < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxObligationCreated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
