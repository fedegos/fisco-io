# frozen_string_literal: true

# Fisco.io - CloseTaxObligationHandler
# Cierra la obligación; persiste TaxObligationClosed, publica.

module Obligations
  module Handlers
    class CloseTaxObligationHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation = @repository.load(cmd.obligation_id, Obligations::TaxObligation)
        raise ArgumentError, "Obligation not found: #{cmd.obligation_id}" unless obligation
        raise ArgumentError, "Obligation is already closed" if obligation.status == "closed"

        event_data = { "closed_at" => Date.current.to_s }
        event = Obligations::Events::TaxObligationClosed.new(
          aggregate_id: cmd.obligation_id,
          data: event_data
        )
        @repository.append(cmd.obligation_id, Obligations::TaxObligation.name, event)
        @event_bus.publish(event)
        { obligation_id: cmd.obligation_id }
      end
    end
  end
end
