# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Handlers::OpenObligationHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste ObligationOpened y devuelve obligation_id" do
      obligation_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid
      cmd = Obligations::Commands::OpenObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: subject_id,
        tax_type: "inmobiliario",
        role: "contribuyente"
      )

      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      loaded = repository.load(obligation_id, Obligations::TaxObligation)
      expect(loaded).to be_a(Obligations::TaxObligation)
      expect(loaded.primary_subject_id).to eq(subject_id)
      expect(loaded.tax_type).to eq("inmobiliario")
      expect(loaded.status).to eq("open")
      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::ObligationOpened))
    end

    it "incluye external_id cuando cumple validación de inmobiliario" do
      obligation_id = SecureRandom.uuid
      cmd = Obligations::Commands::OpenObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        role: "contribuyente",
        external_id: "12-10001"
      )

      handler.call(cmd)

      record = EventRecord.where(aggregate_id: obligation_id).last
      expect(record.data["external_id"]).to eq("12-10001")
    end

    it "lanza ArgumentError si external_id no cumple regex del tax_type" do
      cmd = Obligations::Commands::OpenObligation.new(
        obligation_id: SecureRandom.uuid,
        primary_subject_id: SecureRandom.uuid,
        tax_type: "inmobiliario",
        role: "contribuyente",
        external_id: "invalid"
      )

      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Partido-Partida/)
    end
  end
end
