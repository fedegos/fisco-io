# frozen_string_literal: true

# Fisco.io - ObligationClosed event (business: Cerrar partida)

module Obligations
  module Events
    class ObligationClosed < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "ObligationClosed",
          data: data,
          **kwargs
        )
      end
    end
  end
end
