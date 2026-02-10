# frozen_string_literal: true

# Fisco.io - CeaseSubjectHandler (business: Cesar)

module Identity
  module Handlers
    class CeaseSubjectHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        subject = @repository.load(cmd.aggregate_id, Identity::Subject)
        raise ArgumentError, "Subject not found: #{cmd.aggregate_id}" unless subject

        data = cmd.observations.present? ? { "observations" => cmd.observations } : {}
        event = Identity::Events::SubjectCeased.new(aggregate_id: cmd.aggregate_id, data: data)
        @repository.append(cmd.aggregate_id, Identity::Subject.name, event)
        @event_bus.publish(event)
        { subject_id: cmd.aggregate_id }
      end
    end
  end
end
