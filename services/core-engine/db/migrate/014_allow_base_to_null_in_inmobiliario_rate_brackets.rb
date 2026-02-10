# frozen_string_literal: true

class AllowBaseToNullInInmobiliarioRateBrackets < ActiveRecord::Migration[8.0]
  def change
    change_column_null :inmobiliario_rate_brackets, :base_to, true
  end
end
