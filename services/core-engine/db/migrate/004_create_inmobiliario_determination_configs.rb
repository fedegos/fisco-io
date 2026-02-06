# frozen_string_literal: true

class CreateInmobiliarioDeterminationConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :inmobiliario_determination_configs, id: :uuid do |t|
      t.string :tax_type, null: false, default: "inmobiliario"
      t.integer :year, null: false
      t.string :formula_base_expression, null: false, default: "valuacion * 1.0"
      t.integer :installments_per_year, null: false, default: 4
      t.timestamps
    end
    add_index :inmobiliario_determination_configs, [:tax_type, :year], unique: true, name: "idx_inmob_config_tax_year"
  end
end
