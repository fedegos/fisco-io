# frozen_string_literal: true

class AddDigitalDomicileIdToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :digital_domicile_id, :uuid
  end
end
