# frozen_string_literal: true

# Fisco.io - AccrueInterest command
# Devengar intereses / Accrue interest

module Obligations
  module Commands
    class AccrueInterest < BaseCommand
      attr_reader :obligation_id, :debt_id, :accrual_date, :interest_amount

      def initialize(aggregate_id:, obligation_id:, debt_id:, accrual_date:, interest_amount:, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @obligation_id = obligation_id
        @debt_id = debt_id
        @accrual_date = accrual_date
        @interest_amount = interest_amount
      end
    end
  end
end
