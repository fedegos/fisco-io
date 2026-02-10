# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeedDemoDataService do
  describe ".call" do
    it "no crea datos cuando ya existen tax_account_balances" do
      TaxAccountBalance.create!(
        obligation_id: SecureRandom.uuid,
        subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        current_balance: 0,
        principal_balance: 0,
        interest_balance: 0,
        updated_at: Time.current,
        version: 0
      )
      count_before = EventRecord.count

      result = described_class.call(
        sujetos: [{ tax_id: "20-1", legal_name: "A", trade_name: nil }],
        obligaciones: [],
        liquidaciones: [],
        pagos: []
      )

      expect(result).to be_nil
      expect(EventRecord.count).to eq(count_before)
    end

    it "crea sujetos y eventos cuando no hay tax_account_balances" do
      expect(TaxAccountBalance.any?).to eq(false)
      sujetos = [{ tax_id: "20-11111111-1", legal_name: "Seed SA", trade_name: "Seed" }]

      result = described_class.call(
        sujetos: sujetos,
        obligaciones: [],
        liquidaciones: [],
        pagos: []
      )

      expect(result).to eq(true)
      expect(EventRecord.where(aggregate_type: "Identity::Subject").count).to eq(1)
      rec = EventRecord.where(aggregate_type: "Identity::Subject").last
      expect(rec.data["legal_name"]).to eq("Seed SA")
    end
  end
end
