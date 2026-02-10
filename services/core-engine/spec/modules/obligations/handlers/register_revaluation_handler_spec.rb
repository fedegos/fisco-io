# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Handlers::RegisterRevaluationHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste RevaluationRegistered cuando la obligación existe y está open" do
      obligation_id = SecureRandom.uuid
      Obligations::Handlers::CreateTaxObligationHandler.new(repository: repository).call(
        Obligations::Commands::CreateTaxObligation.new(
          obligation_id: obligation_id,
          primary_subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          role: "contribuyente"
        )
      )

      cmd = Obligations::Commands::RegisterRevaluation.new(obligation_id: obligation_id, year: 2024, value: 1_500_000)
      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      expect(result[:year]).to eq(2024)
      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record.event_type).to eq("RevaluationRegistered")
      expect(record.data["year"]).to eq(2024)
      expect(record.data["value"]).to eq("1500000.0")
      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::RevaluationRegistered))
    end

    it "lanza ArgumentError cuando la obligación no existe" do
      cmd = Obligations::Commands::RegisterRevaluation.new(obligation_id: SecureRandom.uuid, year: 2024, value: 100)
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
      cmd = Obligations::Commands::RegisterRevaluation.new(obligation_id: obligation_id, year: 2024, value: 100)
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /is closed/)
    end
  end
end
