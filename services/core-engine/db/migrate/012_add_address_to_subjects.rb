# frozen_string_literal: true

class AddAddressToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :address_province, :string
    add_column :subjects, :address_locality, :string
    add_column :subjects, :address_line, :string
  end
end
