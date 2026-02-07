# frozen_string_literal: true

# Fisco.io - CloseTaxObligation command
# Cerrar obligación tributaria (baja lógica) / Close tax obligation

module Obligations
  module Commands
    class CloseTaxObligation < BaseCommand
      attr_reader :obligation_id

      def initialize(aggregate_id: nil, obligation_id: nil, **kwargs)
        oid = aggregate_id || obligation_id
        super(aggregate_id: oid, **kwargs)
        @obligation_id = oid
      end
    end
  end
end
