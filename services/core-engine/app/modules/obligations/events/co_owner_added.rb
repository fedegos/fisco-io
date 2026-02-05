# frozen_string_literal: true

# Fisco.io - CoOwnerAdded event
# Cotitular agregado / Co-owner added

module Obligations
  module Events
    class CoOwnerAdded < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "CoOwnerAdded",
          data: data,
          **kwargs
        )
      end
    end
  end
end
