# frozen_string_literal: true

# Fisco.io - Valuación fiscal por obligación y año (input para cálculo de base imponible)

class FiscalValuation < ActiveRecord::Base
  self.table_name = "fiscal_valuations"

  validates :obligation_id, :year, :value, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2000 }
  validates :value, numericality: { greater_than_or_equal_to: 0 }
  validates :obligation_id, uniqueness: { scope: :year }
end
