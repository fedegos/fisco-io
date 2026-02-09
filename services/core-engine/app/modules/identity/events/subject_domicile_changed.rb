# frozen_string_literal: true

# Fisco.io - SubjectDomicileChanged event (business: Mudar domicilio)

module Identity
  module Events
    class SubjectDomicileChanged < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectDomicileChanged",
          data: data,
          **kwargs
        )
      end
    end
  end
end
