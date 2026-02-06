# frozen_string_literal: true

# Fisco.io - Motor de cálculo de obligación inmobiliaria por período
# Dada base imponible (o valuación + fórmula) y tabla de tramos: calcula impuesto anual y por cuota.

class InmobiliarioCalculationService
  TAX_TYPE = "inmobiliario"

  Result = Struct.new(:annual_amount, :installments, :base_imponible, keyword_init: true)

  class << self
    # Calcula impuesto anual y cuotas para una obligación en un año.
    # valuation: valor de valuación fiscal del objeto en ese año.
    # Si no se pasa base_imponible, se calcula con la fórmula configurada (valuacion * factor).
    def call(obligation_id:, year:, valuation: nil, base_imponible: nil, tax_type: TAX_TYPE)
      config = InmobiliarioDeterminationConfig.find_by(tax_type: tax_type, year: year)
      brackets = InmobiliarioRateBracket.for_tax_year(tax_type, year).to_a

      base = base_imponible || compute_base(valuation, config)
      return Result.new(annual_amount: 0, installments: [], base_imponible: base) if base.nil? || base.zero?
      return Result.new(annual_amount: 0, installments: [], base_imponible: base) if brackets.empty?

      annual = apply_brackets(base, brackets)
      installments_count = config&.installments_per_year || 4
      per_installment = (annual / installments_count).round(2)
      installments = Array.new(installments_count) { per_installment }
      remainder = (annual - (per_installment * installments_count)).round(2)
      installments[0] = (installments[0] + remainder).round(2) if remainder.nonzero?

      Result.new(annual_amount: annual, installments: installments, base_imponible: base)
    end

    # Solo aplica tabla de tramos a una base (para tests o uso directo).
    def apply_brackets(base_imponible, brackets)
      return 0.to_d if brackets.empty? || base_imponible.nil? || base_imponible <= 0

      brackets.sum do |b|
        base_from = b.base_from.to_d
        base_to = b.base_to.to_d
        rate_pct = b.rate_pct.to_d
        minimum = b.minimum_amount.to_d
        next 0.to_d if base_imponible < base_from

        taxable_in_bracket = [base_imponible, base_to].min - base_from
        amount = (taxable_in_bracket * rate_pct / 100).round(2)
        [amount, minimum].max
      end
    end

    private

    def compute_base(valuation, config)
      return nil if valuation.nil?
      return valuation.to_d if config.blank? || config.formula_base_expression.blank?

      # Fórmula simple: "valuacion * 1.0" o "valuacion * 0.85" (extraer factor)
      expr = config.formula_base_expression.strip.downcase
      if expr =~ /\Avaluacion\s*\*\s*([\d.]+)\z/
        (valuation.to_d * Regexp.last_match(1).to_d).round(2)
      else
        valuation.to_d
      end
    end
  end
end
