# frozen_string_literal: true

# Fisco.io - TaxObligationClosed event
# Obligación tributaria cerrada / Tax obligation closed

module Obligations
  module Events
    class TaxObligationClosed < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "TaxObligationClosed",
          data: data,
          **kwargs
        )
      end
    end
  end
end
