# frozen_string_literal: true

# Fisco.io - CreateTaxObligation command
# Crear obligación tributaria / Create tax obligation

module Obligations
  module Commands
    class CreateTaxObligation < BaseCommand
      attr_reader :obligation_id, :primary_subject_id, :tax_type, :role

      def initialize(aggregate_id: nil, obligation_id:, primary_subject_id:, tax_type:, role:, **kwargs)
        super(aggregate_id: (aggregate_id || obligation_id), **kwargs)
        @obligation_id = obligation_id
        @primary_subject_id = primary_subject_id
        @tax_type = tax_type
        @role = role
      end
    end
  end
end
