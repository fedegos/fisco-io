# frozen_string_literal: true

# Fisco.io - Obligations::TaxObligation specs

require "spec_helper"
require "app/aggregates/base_aggregate"
require "app/modules/obligations/tax_account"
require "app/modules/obligations/tax_obligation"

RSpec.describe Obligations::TaxObligation do
  describe ".new" do
    it "inicializa con account por defecto" do
      obl = described_class.new(obligation_id: "obl-1", primary_subject_id: "sub-1", tax_type: "ingresos_brutos", role: "taxpayer")
      expect(obl.account).to be_a(Obligations::TaxAccount)
    end
  end

  describe "#apply_TaxObligationCreated" do
    it "actualiza atributos desde el evento" do
      obl = described_class.new(id: "obl-1")
      event = double(
        "event",
        data: {
          "obligation_id" => "obl-1",
          "primary_subject_id" => "sub-1",
          "tax_type" => "ingresos_brutos",
          "role" => "taxpayer",
          "status" => "active",
          "opened_at" => "2024-01-01"
        },
        event_type: "TaxObligationCreated",
        event_version: 1
      )
      obl.apply(event)
      expect(obl.obligation_id).to eq("obl-1")
      expect(obl.tax_type).to eq("ingresos_brutos")
    end
  end
end
