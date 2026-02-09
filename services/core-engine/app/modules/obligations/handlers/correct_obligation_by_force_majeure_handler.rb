# frozen_string_literal: true

# Fisco.io - CorrectObligationByForceMajeureHandler (business: Corregir por fuerza mayor)

module Obligations
  module Handlers
    class CorrectObligationByForceMajeureHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        raise ArgumentError, "operator_observations is required" if cmd.operator_observations.blank?
        raise ArgumentError, "at least one attribute must be provided" if cmd.attributes.blank?

        obligation = @repository.load(cmd.obligation_id, Obligations::TaxObligation)
        raise ArgumentError, "Obligation not found: #{cmd.obligation_id}" unless obligation
        raise ArgumentError, "Obligation is closed" if obligation.status == "closed"

        if cmd.attributes["external_id"].present?
          ok, err = JurisdictionConfig.validate_external_id(
            tax_type: obligation.tax_type,
            external_id: cmd.attributes["external_id"]
          )
          raise ArgumentError, err unless ok
        end

        event_data = cmd.attributes.merge("operator_observations" => cmd.operator_observations)
        event = Obligations::Events::ObligationCorrectedByForceMajeure.new(
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
