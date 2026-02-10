# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaxAccountBalance do
  describe "#display_id" do
    it "devuelve external_id cuando está presente" do
      balance = TaxAccountBalance.new(
        obligation_id: SecureRandom.uuid,
        subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        external_id: "12-10001"
      )
      expect(balance.display_id).to eq("12-10001")
    end

    it "devuelve obligation_id cuando external_id está en blanco" do
      obligation_id = SecureRandom.uuid
      balance = TaxAccountBalance.new(
        obligation_id: obligation_id,
        subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        external_id: nil
      )
      expect(balance.display_id).to eq(obligation_id)
    end
  end
end
