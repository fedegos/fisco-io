# frozen_string_literal: true

# Fisco.io - RevaluationRegistered event (business: Revalúo)

module Obligations
  module Events
    class RevaluationRegistered < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "RevaluationRegistered",
          data: data,
          **kwargs
        )
      end
    end
  end
end
