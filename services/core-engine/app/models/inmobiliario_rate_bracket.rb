# frozen_string_literal: true

# Fisco.io - Tramo de alícuota para impuesto inmobiliario (base_from - base_to, tasa %, monto mínimo)

class InmobiliarioRateBracket < ActiveRecord::Base
  self.table_name = "inmobiliario_rate_brackets"

  validates :tax_type, :year, :base_from, :rate_pct, :minimum_amount, :position, presence: true
  validates :base_to, numericality: { greater_than_or_equal_to: :base_from }, if: -> { base_to.present? && base_from.present? }
  scope :for_tax_year, ->(tax_type, year) { where(tax_type: tax_type, year: year).order(:position) }
end
