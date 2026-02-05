# frozen_string_literal: true

# Fisco.io - PaymentReceived event
# Pago recibido (emitido por TaxObligation) / Payment received (emitted by TaxObligation)

module Obligations
  module Events
    class PaymentReceived < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "PaymentReceived",
          data: data,
          **kwargs
        )
      end
    end
  end
end
