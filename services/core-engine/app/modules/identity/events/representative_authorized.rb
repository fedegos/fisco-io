# frozen_string_literal: true

# Fisco.io - RepresentativeAuthorized event
# Representante autorizado / Representative authorized

module Identity
  module Events
    class RepresentativeAuthorized < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "RepresentativeAuthorized",
          data: data,
          **kwargs
        )
      end
    end
  end
end
