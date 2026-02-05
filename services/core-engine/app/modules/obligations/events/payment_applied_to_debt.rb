# frozen_string_literal: true

# Fisco.io - PaymentAppliedToDebt event
# Pago aplicado a deuda / Payment applied to debt

module Obligations
  module Events
    class PaymentAppliedToDebt < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "PaymentAppliedToDebt",
          data: data,
          **kwargs
        )
      end
    end
  end
end
