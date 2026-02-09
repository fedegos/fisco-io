# frozen_string_literal: true

# Fisco.io - SubjectContactDataUpdated event (business: Actualizar datos de contacto)

module Identity
  module Events
    class SubjectContactDataUpdated < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectContactDataUpdated",
          data: data,
          **kwargs
        )
      end
    end
  end
end
