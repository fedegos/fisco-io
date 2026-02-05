# frozen_string_literal: true

# Fisco.io - Tax account balances projection table
# Read model para saldos por obligación (proyección de eventos de obligaciones)

class CreateTaxAccountBalancesProjection < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_account_balances, id: false do |t|
      t.uuid :obligation_id, null: false, primary_key: true
      t.uuid :subject_id, null: false
      t.string :tax_type, null: false
      t.decimal :current_balance, precision: 15, scale: 2, null: false, default: 0
      t.decimal :principal_balance, precision: 15, scale: 2, null: false, default: 0
      t.decimal :interest_balance, precision: 15, scale: 2, null: false, default: 0
      t.date :last_payment_date
      t.date :last_liquidation_date
      t.integer :version, null: false, default: 0
      t.timestamps
    end

    add_index :tax_account_balances, :subject_id, name: "idx_tax_account_balances_subject_id"
    add_index :tax_account_balances, :tax_type, name: "idx_tax_account_balances_tax_type"
  end
end
