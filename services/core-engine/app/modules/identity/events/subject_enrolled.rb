# frozen_string_literal: true

# Fisco.io - SubjectEnrolled event (business: Empadronar)

module Identity
  module Events
    class SubjectEnrolled < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectEnrolled",
          data: data,
          **kwargs
        )
      end
    end
  end
end
