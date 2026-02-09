# frozen_string_literal: true

# Fisco.io - SubjectCorrectedByForceMajeure event (business: Corregir por fuerza mayor)
# Subject data corrected by force majeure

module Identity
  module Events
    class SubjectCorrectedByForceMajeure < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectCorrectedByForceMajeure",
          data: data,
          **kwargs
        )
      end
    end
  end
end
