# frozen_string_literal: true

# Fisco.io - OpenObligation command (business: Abrir partida)

module Obligations
  module Commands
    class OpenObligation < BaseCommand
      attr_reader :obligation_id, :primary_subject_id, :tax_type, :role, :external_id

      def initialize(aggregate_id: nil, obligation_id:, primary_subject_id:, tax_type:, role:, external_id: nil, **kwargs)
        super(aggregate_id: (aggregate_id || obligation_id), **kwargs)
        @obligation_id = obligation_id
        @primary_subject_id = primary_subject_id
        @tax_type = tax_type
        @role = role
        @external_id = external_id.presence
      end
    end
  end
end
