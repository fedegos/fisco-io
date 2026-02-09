# frozen_string_literal: true

# Fisco.io - CloseObligation command (business: Cerrar partida)

module Obligations
  module Commands
    class CloseObligation < BaseCommand
      attr_reader :obligation_id

      def initialize(aggregate_id: nil, obligation_id: nil, **kwargs)
        oid = aggregate_id || obligation_id
        super(aggregate_id: oid, **kwargs)
        @obligation_id = oid
      end
    end
  end
end
