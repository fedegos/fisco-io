# frozen_string_literal: true

# Fisco.io - Add external_id to tax_account_balances
# Identificador mostrable por obligación (partido-partida, CUIT, patente, etc.)

class AddExternalIdToTaxAccountBalances < ActiveRecord::Migration[8.0]
  def change
    add_column :tax_account_balances, :external_id, :string
    add_index :tax_account_balances, [:tax_type, :external_id],
              name: "idx_tax_account_balances_tax_type_external_id",
              unique: true,
              where: "external_id IS NOT NULL AND external_id != ''"
  end
end
