# frozen_string_literal: true

# Fisco.io - CreateLiquidationHandler
# Ejecuta CreateLiquidation: persiste TaxLiquidationCreated (scaffolding).

module Obligations
  module Handlers
    class CreateLiquidationHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation_id = cmd.aggregate_id
        event_data = {
          "obligation_id" => obligation_id,
          "period" => cmd.period.to_s,
          "amount" => cmd.amount.to_s
        }

        event = Obligations::Events::TaxLiquidationCreated.new(
          aggregate_id: obligation_id,
          data: event_data
        )

        @repository.append(obligation_id, Obligations::TaxObligation.name, event)
        @event_bus.publish(event)

        { obligation_id: obligation_id, period: cmd.period, amount: cmd.amount }
      end
    end
  end
end
