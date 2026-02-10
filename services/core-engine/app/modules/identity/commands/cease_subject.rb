# frozen_string_literal: true

# Fisco.io - CeaseSubject command (business: Cesar)
# Baja del sujeto con observaciones opcionales

module Identity
  module Commands
    class CeaseSubject < BaseCommand
      attr_reader :observations

      def initialize(aggregate_id:, observations: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @observations = observations.to_s.strip.presence
      end
    end
  end
end
