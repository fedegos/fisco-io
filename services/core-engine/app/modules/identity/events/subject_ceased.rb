# frozen_string_literal: true

# Fisco.io - SubjectCeased event (business: Cesar)
# Subject ceased (deactivated)

module Identity
  module Events
    class SubjectCeased < BaseEvent
      def initialize(aggregate_id:, data: {}, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectCeased",
          data: data,
          **kwargs
        )
      end
    end
  end
end
