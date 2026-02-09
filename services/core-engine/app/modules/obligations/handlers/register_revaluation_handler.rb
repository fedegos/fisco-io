# frozen_string_literal: true

# Fisco.io - RegisterRevaluationHandler (business: Revalúo)

module Obligations
  module Handlers
    class RegisterRevaluationHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation = @repository.load(cmd.obligation_id, Obligations::TaxObligation)
        raise ArgumentError, "Obligation not found: #{cmd.obligation_id}" unless obligation
        raise ArgumentError, "Obligation is closed" if obligation.status == "closed"

        event_data = {
          "obligation_id" => cmd.obligation_id,
          "year" => cmd.year,
          "value" => cmd.value.to_s
        }
        event_data["operator_observations"] = cmd.operator_observations if cmd.operator_observations.present?

        event = Obligations::Events::RevaluationRegistered.new(
          aggregate_id: cmd.obligation_id,
          data: event_data
        )
        @repository.append(cmd.obligation_id, Obligations::TaxObligation.name, event)
        @event_bus.publish(event)
        { obligation_id: cmd.obligation_id, year: cmd.year }
      end
    end
  end
end
