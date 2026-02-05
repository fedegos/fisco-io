# frozen_string_literal: true

# Fisco.io - Obligations::Handlers::CreateTaxObligationHandler specs

require "rails_helper"

RSpec.describe Obligations::Handlers::CreateTaxObligationHandler do
  let(:repository) { EventStore::Repository.new }
  let(:handler) { described_class.new(repository: repository) }

  describe "#call" do
    it "persiste TaxObligationCreated y devuelve obligation_id" do
      obligation_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid
      cmd = Obligations::Commands::CreateTaxObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: subject_id,
        tax_type: "ingresos_brutos",
        role: "taxpayer"
      )

      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)

      loaded = repository.load(obligation_id, Obligations::TaxObligation)
      expect(loaded).to be_a(Obligations::TaxObligation)
      expect(loaded.obligation_id).to eq(obligation_id)
      expect(loaded.primary_subject_id).to eq(subject_id)
      expect(loaded.tax_type).to eq("ingresos_brutos")
      expect(loaded.role).to eq("taxpayer")
      expect(loaded.status).to eq("open")
    end

    it "usa aggregate_id del comando si se provee" do
      obligation_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid
      cmd = Obligations::Commands::CreateTaxObligation.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        primary_subject_id: subject_id,
        tax_type: "inmobiliario",
        role: "taxpayer"
      )

      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      loaded = repository.load(obligation_id, Obligations::TaxObligation)
      expect(loaded.obligation_id).to eq(obligation_id)
    end
  end
end
