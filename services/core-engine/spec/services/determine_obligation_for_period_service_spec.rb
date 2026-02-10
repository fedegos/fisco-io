# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineObligationForPeriodService do
  let(:create_liquidation_handler) { instance_double(Obligations::Handlers::CreateLiquidationHandler, call: {}) }
  let(:service) { described_class.new(create_liquidation_handler: create_liquidation_handler) }

  describe "#call" do
    it "devuelve liquidations vacías y message cuando no hay config o valuación (annual_amount zero)" do
      allow(InmobiliarioCalculationService).to receive(:call).and_return(
        double(annual_amount: 0, installments: [])
      )
      allow(FiscalValuation).to receive(:find_by).and_return(nil)

      result = service.call(obligation_id: SecureRandom.uuid, year: 2024)

      expect(result[:liquidations]).to eq([])
      expect(result[:message]).to eq("no_config_or_valuation")
      expect(create_liquidation_handler).not_to have_received(:call)
    end

    it "crea liquidaciones por cuota cuando hay installments no cero" do
      obligation_id = SecureRandom.uuid
      allow(InmobiliarioCalculationService).to receive(:call).and_return(
        double(annual_amount: 1200, installments: [100.0, 100.0, 100.0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
      )
      allow(FiscalValuation).to receive(:find_by).and_return(double(value: 500_000))

      result = service.call(obligation_id: obligation_id, year: 2024)

      expect(result[:obligation_id]).to eq(obligation_id)
      expect(result[:year]).to eq(2024)
      expect(result[:liquidations].size).to eq(3)
      expect(result[:annual_amount]).to eq(1200)
      expect(create_liquidation_handler).to have_received(:call).exactly(3).times
    end
  end
end
