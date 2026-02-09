# frozen_string_literal: true

# Fisco.io - ObligationOpened event (business: Abrir partida)

module Obligations
  module Events
    class ObligationOpened < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "ObligationOpened",
          data: data,
          **kwargs
        )
      end
    end
  end
end
