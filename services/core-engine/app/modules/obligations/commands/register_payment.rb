# frozen_string_literal: true

# Fisco.io - RegisterPayment command
# Registrar pago en obligación / Register payment on obligation

module Obligations
  module Commands
    class RegisterPayment < BaseCommand
      attr_reader :obligation_id, :amount, :allocations

      def initialize(aggregate_id:, obligation_id:, amount:, allocations: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @obligation_id = obligation_id
        @amount = amount
        @allocations = allocations
      end
    end
  end
end
