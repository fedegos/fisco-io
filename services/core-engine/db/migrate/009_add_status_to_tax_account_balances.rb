# frozen_string_literal: true

class AddStatusToTaxAccountBalances < ActiveRecord::Migration[8.0]
  def change
    add_column :tax_account_balances, :status, :string, default: "open", null: false
    add_column :tax_account_balances, :closed_at, :date
  end
end
