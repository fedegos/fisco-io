# frozen_string_literal: true

# Fisco.io - CreateLiquidation command
# Crear liquidación tributaria / Create tax liquidation

module Obligations
  module Commands
    class CreateLiquidation < BaseCommand
      attr_reader :obligation_id, :period, :amount

      def initialize(aggregate_id:, obligation_id:, period:, amount:, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @obligation_id = obligation_id
        @period = period
        @amount = amount
      end
    end
  end
end
