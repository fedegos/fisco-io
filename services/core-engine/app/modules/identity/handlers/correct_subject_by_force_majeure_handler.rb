# frozen_string_literal: true

# Fisco.io - CorrectSubjectByForceMajeureHandler (business: Corregir por fuerza mayor)

module Identity
  module Handlers
    class CorrectSubjectByForceMajeureHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        raise ArgumentError, "operator_observations is required" if cmd.operator_observations.blank?
        raise ArgumentError, "at least one attribute must be provided" if cmd.attributes.blank?

        subject = @repository.load(cmd.aggregate_id, Identity::Subject)
        raise ArgumentError, "Subject not found: #{cmd.aggregate_id}" unless subject

        event_data = cmd.attributes.merge("operator_observations" => cmd.operator_observations)
        event = Identity::Events::SubjectCorrectedByForceMajeure.new(
          aggregate_id: cmd.aggregate_id,
          data: event_data
        )
        @repository.append(cmd.aggregate_id, Identity::Subject.name, event)
        @event_bus.publish(event)
        { subject_id: cmd.aggregate_id }
      end
    end
  end
end
