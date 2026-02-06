# frozen_string_literal: true

class CreateInmobiliarioRateBrackets < ActiveRecord::Migration[8.0]
  def change
    create_table :inmobiliario_rate_brackets, id: :uuid do |t|
      t.string :tax_type, null: false, default: "inmobiliario"
      t.integer :year, null: false
      t.decimal :base_from, precision: 15, scale: 2, null: false, default: 0
      t.decimal :base_to, precision: 15, scale: 2, null: false
      t.decimal :rate_pct, precision: 8, scale: 4, null: false
      t.decimal :minimum_amount, precision: 15, scale: 2, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :inmobiliario_rate_brackets, [:tax_type, :year], name: "idx_inmob_brackets_tax_year"
  end
end
