# frozen_string_literal: true

# Fisco.io - RegisterSubjectHandler
# Ejecuta RegisterSubject: crea Subject, persiste SubjectRegistered, publica en bus.
# Vinculo event store → Kafka: append primero (fuente de verdad), luego publish.

module Identity
  module Handlers
    class RegisterSubjectHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        subject_id = cmd.aggregate_id || SecureRandom.uuid
        event_data = {
          "subject_id" => subject_id,
          "tax_id" => cmd.tax_id,
          "legal_name" => cmd.legal_name,
          "trade_name" => cmd.trade_name,
          "status" => "active",
          "registration_date" => Date.current.to_s
        }

        event = Identity::Events::SubjectRegistered.new(
          aggregate_id: subject_id,
          data: event_data
        )

        @repository.append(subject_id, Identity::Subject.name, event)
        @event_bus.publish(event)

        { subject_id: subject_id }
      end
    end
  end
end
