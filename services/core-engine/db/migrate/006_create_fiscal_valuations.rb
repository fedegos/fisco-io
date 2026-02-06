# frozen_string_literal: true

class CreateFiscalValuations < ActiveRecord::Migration[8.0]
  def change
    create_table :fiscal_valuations, id: :uuid do |t|
      t.uuid :obligation_id, null: false
      t.integer :year, null: false
      t.decimal :value, precision: 15, scale: 2, null: false
      t.timestamps
    end
    add_index :fiscal_valuations, [:obligation_id, :year], unique: true, name: "idx_fiscal_valuations_oblig_year"
  end
end
