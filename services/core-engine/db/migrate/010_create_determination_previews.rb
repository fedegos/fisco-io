# frozen_string_literal: true

class CreateDeterminationPreviews < ActiveRecord::Migration[8.0]
  def change
    create_table :determination_previews, id: :uuid do |t|
      t.integer :year, null: false
      t.uuid :obligation_id, null: false
      t.string :status, default: "draft", null: false
      t.jsonb :payload, null: false, default: []
      t.timestamps
    end
    add_index :determination_previews, [:year, :obligation_id], unique: true
    add_index :determination_previews, :year
  end
end
