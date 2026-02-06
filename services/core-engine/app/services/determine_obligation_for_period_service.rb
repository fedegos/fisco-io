# frozen_string_literal: true

# Fisco.io - Determina obligación para un año usando el motor inmobiliario y emite liquidaciones por cuota.
# Integra InmobiliarioCalculationService con el event store (CreateLiquidation).

class DetermineObligationForPeriodService
  def initialize(create_liquidation_handler: nil)
    @create_liquidation_handler = create_liquidation_handler || Obligations::Handlers::CreateLiquidationHandler.new
  end

  def call(obligation_id:, year:)
    valuation = FiscalValuation.find_by(obligation_id: obligation_id, year: year)&.value
    result = InmobiliarioCalculationService.call(obligation_id: obligation_id, year: year, valuation: valuation)

    return { obligation_id: obligation_id, year: year, liquidations: [], message: "no_config_or_valuation" } if result.annual_amount.zero?

    liquidations_created = []
    result.installments.each_with_index do |amount, idx|
      next if amount.zero?
      period = "#{year}-%02d" % (idx + 1)
      cmd = Obligations::Commands::CreateLiquidation.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        period: period,
        amount: amount
      )
      @create_liquidation_handler.call(cmd)
      liquidations_created << { period: period, amount: amount }
    end
    { obligation_id: obligation_id, year: year, liquidations: liquidations_created, annual_amount: result.annual_amount }
  end
end
