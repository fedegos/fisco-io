# frozen_string_literal: true

# Fisco.io - CeaseSubject command (business: Cesar)

module Identity
  module Commands
    class CeaseSubject < BaseCommand
      def initialize(aggregate_id:, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
      end
    end
  end
end
