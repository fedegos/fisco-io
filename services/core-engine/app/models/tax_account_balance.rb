# frozen_string_literal: true

# Fisco.io - Tax account balance read model
# Modelo para la tabla tax_account_balances (proyección de saldos por obligación)

class TaxAccountBalance < ActiveRecord::Base
  self.table_name = "tax_account_balances"
  self.primary_key = "obligation_id"

  # obligation_id (uuid PK), subject_id, tax_type, external_id (mostrable), current_balance, ...
  validates :obligation_id, :subject_id, :tax_type, presence: true

  # Identificador a mostrar a sujetos externos (no UUID)
  def display_id
    external_id.presence || obligation_id
  end
end
