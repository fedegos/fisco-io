# frozen_string_literal: true

# Fisco.io - RegisterSubject command
# Registrar un sujeto / Register a subject

module Identity
  module Commands
    class RegisterSubject < BaseCommand
      attr_reader :tax_id, :legal_name, :trade_name

      def initialize(aggregate_id: nil, tax_id:, legal_name:, trade_name: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @tax_id = tax_id
        @legal_name = legal_name
        @trade_name = trade_name
      end
    end
  end
end
