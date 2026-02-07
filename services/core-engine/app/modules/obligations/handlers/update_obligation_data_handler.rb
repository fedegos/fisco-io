# frozen_string_literal: true

# Fisco.io - UpdateObligationDataHandler
# Actualiza datos editables de la obligación (external_id); persiste TaxObligationUpdated.

module Obligations
  module Handlers
    class UpdateObligationDataHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation = @repository.load(cmd.obligation_id, Obligations::TaxObligation)
        raise ArgumentError, "Obligation not found: #{cmd.obligation_id}" unless obligation
        raise ArgumentError, "Obligation is closed" if obligation.status == "closed"

        if cmd.external_id.present?
          ok, err = JurisdictionConfig.validate_external_id(
            tax_type: obligation.tax_type,
            external_id: cmd.external_id
          )
          raise ArgumentError, err unless ok
        end

        event_data = {}
        event_data["external_id"] = cmd.external_id if !cmd.external_id.nil?
        event = Obligations::Events::TaxObligationUpdated.new(
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
