# frozen_string_literal: true

# Fisco.io - Tax account balance read model
# Modelo para la tabla tax_account_balances (proyección de saldos por obligación)

class TaxAccountBalance < ActiveRecord::Base
  self.table_name = "tax_account_balances"
  self.primary_key = "obligation_id"

  # obligation_id (uuid PK), subject_id, tax_type, current_balance, principal_balance,
  # interest_balance, last_payment_date, last_liquidation_date, version, created_at, updated_at
  validates :obligation_id, :subject_id, :tax_type, presence: true
end
