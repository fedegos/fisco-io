# frozen_string_literal: true

# Fisco.io - SubjectRegistered event
# Sujeto registrado en el sistema / Subject registered in the system

module Identity
  module Events
    class SubjectRegistered < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectRegistered",
          data: data,
          **kwargs
        )
      end
    end
  end
end
