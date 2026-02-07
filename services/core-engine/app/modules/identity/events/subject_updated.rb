# frozen_string_literal: true

# Fisco.io - SubjectUpdated event
# Datos del sujeto actualizados / Subject data updated

module Identity
  module Events
    class SubjectUpdated < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectUpdated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
