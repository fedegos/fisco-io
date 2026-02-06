# frozen_string_literal: true

# Fisco.io - Configuración de determinación por tipo de impuesto y año (inmobiliario)
# Fórmula para base imponible desde valuación y cantidad de cuotas por año

class InmobiliarioDeterminationConfig < ActiveRecord::Base
  self.table_name = "inmobiliario_determination_configs"

  validates :tax_type, :year, :formula_base_expression, :installments_per_year, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2000 }
  validates :installments_per_year, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 }
  validates :tax_type, uniqueness: { scope: :year }
end
