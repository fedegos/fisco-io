# frozen_string_literal: true

# Fisco.io - ChangeSubjectDomicileHandler (business: Mudar domicilio)

module Identity
  module Handlers
    class ChangeSubjectDomicileHandler
      def initialize(repository: nil, event_bus: nil)
        @repository = repository || EventStore::Repository.new
        @event_bus = event_bus || EventStore::EventBus.new
      end

      def call(cmd)
        subject = @repository.load(cmd.aggregate_id, Identity::Subject)
        raise ArgumentError, "Subject not found: #{cmd.aggregate_id}" unless subject

        event_data = {
          "address_province" => cmd.address_province,
          "address_locality" => cmd.address_locality,
          "address_line" => cmd.address_line,
          "digital_domicile_id" => cmd.digital_domicile_id&.to_s
        }.compact
        event = Identity::Events::SubjectDomicileChanged.new(
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
