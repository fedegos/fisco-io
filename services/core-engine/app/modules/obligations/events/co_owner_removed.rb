# frozen_string_literal: true

# Fisco.io - CoOwnerRemoved event
# Cotitular removido / Co-owner removed

module Obligations
  module Events
    class CoOwnerRemoved < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "CoOwnerRemoved",
          data: data,
          **kwargs
        )
      end
    end
  end
end
