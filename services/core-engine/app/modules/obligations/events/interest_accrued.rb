# frozen_string_literal: true

# Fisco.io - InterestAccrued event
# Interés devengado / Interest accrued

module Obligations
  module Events
    class InterestAccrued < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "InterestAccrued",
          data: data,
          **kwargs
        )
      end
    end
  end
end
