# frozen_string_literal: true

# Fisco.io - Genera precálculo inmobiliario por año (sin persistir liquidaciones).
# Guarda resultados en determination_previews con status draft.

class InmobiliarioPrecalculationService
  def call(year:)
    obligation_ids = TaxAccountBalance
      .where(tax_type: "inmobiliario")
      .where.not(obligation_id: DeterminationPreview.where(year: year).select(:obligation_id))
      .pluck(:obligation_id)

    obligations_with_valuation = obligation_ids.select do |oid|
      FiscalValuation.exists?(obligation_id: oid, year: year)
    end

    created = 0
    obligations_with_valuation.each do |obligation_id|
      valuation = FiscalValuation.find_by(obligation_id: obligation_id, year: year)&.value
      result = InmobiliarioCalculationService.call(
        obligation_id: obligation_id,
        year: year,
        valuation: valuation
      )
      next if result.annual_amount.zero?

      payload = result.installments.each_with_index.map do |amount, idx|
        period = "#{year}-%02d" % (idx + 1)
        { "period" => period, "amount" => amount.to_f }
      end
      DeterminationPreview.find_or_initialize_by(year: year, obligation_id: obligation_id).tap do |p|
        p.status = "draft"
        p.payload = payload
        p.save!
        created += 1
      end
    end
    { year: year, created: created, total_obligations: obligations_with_valuation.size }
  end
end
