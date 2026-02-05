# frozen_string_literal: true

# Fisco.io - RepresentativeRevoked event
# Representante revocado / Representative revoked

module Identity
  module Events
    class RepresentativeRevoked < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "RepresentativeRevoked",
          data: data,
          **kwargs
        )
      end
    end
  end
end
