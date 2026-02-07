# frozen_string_literal: true

# Fisco.io - CreateTaxObligationHandler
# Ejecuta CreateTaxObligation: persiste TaxObligationCreated, publica en el bus.

module Obligations
  module Handlers
    class CreateTaxObligationHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        obligation_id = cmd.aggregate_id || cmd.obligation_id
        if cmd.external_id.present?
          ok, err = JurisdictionConfig.validate_external_id(
            tax_type: cmd.tax_type,
            external_id: cmd.external_id
          )
          raise ArgumentError, err unless ok
        end
        event_data = {
          "obligation_id" => obligation_id,
          "primary_subject_id" => cmd.primary_subject_id,
          "tax_type" => cmd.tax_type,
          "role" => cmd.role,
          "status" => "open",
          "opened_at" => Date.current.to_s
        }
        event_data["external_id"] = cmd.external_id if cmd.external_id.present?

        event = Obligations::Events::TaxObligationCreated.new(
          aggregate_id: obligation_id,
          data: event_data
        )

        @repository.append(obligation_id, Obligations::TaxObligation.name, event)
        @event_bus.publish(event)

        { obligation_id: obligation_id }
      end
    end
  end
end
