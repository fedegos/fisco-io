# frozen_string_literal: true

# Fisco.io - ObligationCorrectedByForceMajeure event (business: Corregir por fuerza mayor)

module Obligations
  module Events
    class ObligationCorrectedByForceMajeure < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "ObligationCorrectedByForceMajeure",
          data: data,
          **kwargs
        )
      end
    end
  end
end
