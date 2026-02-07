# frozen_string_literal: true

# Fisco.io - UpdateObligationData command
# Actualizar datos editables de una obligación (ej. external_id) / Update editable obligation data

module Obligations
  module Commands
    class UpdateObligationData < BaseCommand
      attr_reader :obligation_id, :external_id

      def initialize(aggregate_id: nil, obligation_id:, external_id: nil, **kwargs)
        oid = aggregate_id || obligation_id
        super(aggregate_id: oid, **kwargs)
        @obligation_id = oid
        @external_id = external_id.presence
      end
    end
  end
end
