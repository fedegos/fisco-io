# frozen_string_literal: true

# Fisco.io - Subjects projection table
# Read model para sujetos (proyección de eventos de identidad)

class CreateSubjectsProjection < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects, id: false do |t|
      t.uuid :subject_id, null: false, primary_key: true
      t.string :tax_id, null: false
      t.string :legal_name, null: false
      t.string :trade_name
      t.string :status, null: false, default: "active"
      t.date :registration_date, null: false
      t.timestamps
    end

    add_index :subjects, :tax_id, name: "idx_subjects_tax_id"
    add_index :subjects, :status, name: "idx_subjects_status"
  end
end
