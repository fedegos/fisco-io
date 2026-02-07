# frozen_string_literal: true

# Fisco.io - SubjectDeactivated event
# Sujeto desactivado (baja lógica) / Subject deactivated (logical delete)

module Identity
  module Events
    class SubjectDeactivated < BaseEvent
      def initialize(aggregate_id:, data: {}, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectDeactivated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
