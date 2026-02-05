# frozen_string_literal: true

# Fisco.io - RegisterPaymentHandler
# Ejecuta RegisterPayment: persiste PaymentReceived (scaffolding).

module Obligations
  module Handlers
    class RegisterPaymentHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation_id = cmd.aggregate_id
        event_data = {
          "obligation_id" => obligation_id,
          "amount" => cmd.amount.to_s,
          "allocations" => cmd.allocations
        }.compact

        event = Obligations::Events::PaymentReceived.new(
          aggregate_id: obligation_id,
          data: event_data
        )

        @repository.append(obligation_id, Obligations::TaxObligation.name, event)
        @event_bus.publish(event)

        { obligation_id: obligation_id, amount: cmd.amount }
      end
    end
  end
end
