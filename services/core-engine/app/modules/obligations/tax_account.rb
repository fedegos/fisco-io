# frozen_string_literal: true

# Fisco.io - TaxAccount entity
# Cuenta corriente (doble entrada) dentro de una obligación
# Current account (double-entry) within an obligation

module Obligations
  class TaxAccount
    attr_accessor :obligation_id, :current_balance, :principal_balance,
                  :interest_balance, :last_payment_date, :last_liquidation_date

    def initialize(obligation_id: nil, current_balance: 0, principal_balance: 0,
                   interest_balance: 0, last_payment_date: nil, last_liquidation_date: nil)
      @obligation_id = obligation_id
      @current_balance = current_balance
      @principal_balance = principal_balance
      @interest_balance = interest_balance
      @last_payment_date = last_payment_date
      @last_liquidation_date = last_liquidation_date
    end
  end
end
