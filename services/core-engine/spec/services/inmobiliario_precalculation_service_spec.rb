# frozen_string_literal: true

require "rails_helper"

RSpec.describe InmobiliarioPrecalculationService do
  describe "#call" do
    it "devuelve created 0 y total 0 cuando no hay obligaciones inmobiliario" do
      TaxAccountBalance.where(tax_type: "inmobiliario").delete_all if TaxAccountBalance.table_exists?

      result = described_class.new.call(year: 2024)

      expect(result[:year]).to eq(2024)
      expect(result[:created]).to eq(0)
      expect(result[:total_obligations]).to eq(0)
    end

    it "crea determination_previews para obligaciones con valuación y monto anual" do
      obligation_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid
      TaxAccountBalance.create!(
        obligation_id: obligation_id,
        subject_id: subject_id,
        tax_type: "inmobiliario",
        current_balance: 0,
        principal_balance: 0,
        interest_balance: 0,
        updated_at: Time.current,
        version: 0
      )
      FiscalValuation.create!(obligation_id: obligation_id, year: 2024, value: 400_000)
      allow(InmobiliarioCalculationService).to receive(:call).and_return(
        double(annual_amount: 2000, installments: [200.0] * 12)
      )

      result = described_class.new.call(year: 2024)

      expect(result[:year]).to eq(2024)
      expect(result[:created]).to eq(1)
      expect(result[:total_obligations]).to eq(1)
      preview = DeterminationPreview.find_by(year: 2024, obligation_id: obligation_id)
      expect(preview).to be_present
      expect(preview.status).to eq("draft")
      expect(preview.payload.size).to eq(12)
    end
  end
end
