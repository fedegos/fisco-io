# frozen_string_literal: true

# Fisco.io - Obligations::TaxAccount specs

require "spec_helper"
require "app/modules/obligations/tax_account"

RSpec.describe Obligations::TaxAccount do
  describe ".new" do
    it "inicializa con balances en 0 por defecto" do
      account = described_class.new(obligation_id: "obl-1")
      expect(account.current_balance).to eq(0)
      expect(account.principal_balance).to eq(0)
    end
  end
end
