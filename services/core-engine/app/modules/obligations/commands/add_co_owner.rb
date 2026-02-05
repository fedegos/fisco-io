# frozen_string_literal: true

# Fisco.io - AddCoOwner command
# Agregar cotitular / Add co-owner

module Obligations
  module Commands
    class AddCoOwner < BaseCommand
      attr_reader :obligation_id, :subject_id, :ownership_percentage, :is_primary

      def initialize(aggregate_id:, obligation_id:, subject_id:, ownership_percentage: nil, is_primary: false, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @obligation_id = obligation_id
        @subject_id = subject_id
        @ownership_percentage = ownership_percentage
        @is_primary = is_primary
      end
    end
  end
end
