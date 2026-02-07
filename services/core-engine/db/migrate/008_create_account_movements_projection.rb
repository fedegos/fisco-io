# frozen_string_literal: true

# Fisco.io - Account movements projection (cuenta corriente)
# Read model: movimientos por obligación (débitos y créditos)

class CreateAccountMovementsProjection < ActiveRecord::Migration[8.0]
  def change
    create_table :account_movements, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :obligation_id, null: false
      t.string :movement_type, null: false  # liquidation, payment, interest, other
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :debit_credit, null: false  # debit, credit
      t.date :movement_date, null: false
      t.string :period  # ej. 2024-01
      t.string :reference
      t.timestamps
    end

    add_index :account_movements, :obligation_id, name: "idx_account_movements_obligation_id"
    add_index :account_movements, [:obligation_id, :movement_date],
              name: "idx_account_movements_obligation_date"
  end
end
