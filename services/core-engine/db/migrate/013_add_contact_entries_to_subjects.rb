# frozen_string_literal: true

class AddContactEntriesToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :contact_entries, :jsonb, default: []
  end
end
