# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Handlers::UpdateObligationDataHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste TaxObligationUpdated con external_id cuando la obligación está open" do
      obligation_id = SecureRandom.uuid
      Obligations::Handlers::CreateTaxObligationHandler.new(repository: repository).call(
        Obligations::Commands::CreateTaxObligation.new(
          obligation_id: obligation_id,
          primary_subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          role: "contribuyente",
          external_id: "12-10001"
        )
      )

      cmd = Obligations::Commands::UpdateObligationData.new(obligation_id: obligation_id, external_id: "12-10002")
      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record.event_type).to eq("TaxObligationUpdated")
      expect(record.data["external_id"]).to eq("12-10002")
      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::TaxObligationUpdated))
    end

    it "lanza ArgumentError cuando la obligación no existe" do
      cmd = Obligations::Commands::UpdateObligationData.new(obligation_id: SecureRandom.uuid, external_id: "12-1")
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Obligation not found/)
    end

    it "lanza ArgumentError cuando la obligación está closed" do
      obligation_id = SecureRandom.uuid
      Obligations::Handlers::CreateTaxObligationHandler.new(repository: repository).call(
        Obligations::Commands::CreateTaxObligation.new(
          obligation_id: obligation_id,
          primary_subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          role: "contribuyente"
        )
      )
      Obligations::Handlers::CloseObligationHandler.new(repository: repository, event_bus: event_bus).call(
        Obligations::Commands::CloseObligation.new(obligation_id: obligation_id)
      )

      cmd = Obligations::Commands::UpdateObligationData.new(obligation_id: obligation_id, external_id: "12-1")
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /is closed/)
    end
  end
end
