# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Handlers::CloseTaxObligationHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste TaxObligationClosed cuando la obligación existe y está open" do
      obligation_id = SecureRandom.uuid
      Obligations::Handlers::CreateTaxObligationHandler.new(repository: repository).call(
        Obligations::Commands::CreateTaxObligation.new(
          obligation_id: obligation_id,
          primary_subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          role: "contribuyente"
        )
      )

      cmd = Obligations::Commands::CloseTaxObligation.new(obligation_id: obligation_id)
      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      loaded = repository.load(obligation_id, Obligations::TaxObligation)
      expect(loaded.status).to eq("closed")
      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record.event_type).to eq("TaxObligationClosed")
      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::TaxObligationClosed))
    end

    it "lanza ArgumentError cuando la obligación no existe" do
      cmd = Obligations::Commands::CloseTaxObligation.new(obligation_id: SecureRandom.uuid)
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Obligation not found/)
    end
  end
end
