# frozen_string_literal: true

# Fisco.io - UpdateSubjectContactDataHandler (business: Actualizar datos de contacto)

module Identity
  module Handlers
    class UpdateSubjectContactDataHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        subject = @repository.load(cmd.aggregate_id, Identity::Subject)
        raise ArgumentError, "Subject not found: #{cmd.aggregate_id}" unless subject

        event_data = {
          "legal_name" => cmd.legal_name,
          "trade_name" => cmd.trade_name,
          "contact_entries" => cmd.contact_entries
        }.compact
        event = Identity::Events::SubjectContactDataUpdated.new(
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
