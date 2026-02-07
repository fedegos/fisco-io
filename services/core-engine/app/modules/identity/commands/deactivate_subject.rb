# frozen_string_literal: true

# Fisco.io - DeactivateSubject command
# Baja lógica del sujeto / Logical deactivation of subject

module Identity
  module Commands
    class DeactivateSubject < BaseCommand
      def initialize(aggregate_id:, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
      end
    end
  end
end
