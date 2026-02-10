# frozen_string_literal: true

# Fisco.io - Identity::Handlers::UpdateSubjectContactDataHandler specs

require "rails_helper"

RSpec.describe Identity::Handlers::UpdateSubjectContactDataHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste SubjectContactDataUpdated y actualiza legal_name y trade_name" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(
        Identity::Commands::RegisterSubject.new(
          aggregate_id: subject_id,
          tax_id: "20-11111111-1",
          legal_name: "Original SA"
        )
      )

      cmd = Identity::Commands::UpdateSubjectContactData.new(
        aggregate_id: subject_id,
        legal_name: "Actualizado SA",
        trade_name: "Actualizado"
      )
      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)

      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded.legal_name).to eq("Actualizado SA")
      expect(loaded.trade_name).to eq("Actualizado")

      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.event_type).to eq("SubjectContactDataUpdated")
      expect(record.data["legal_name"]).to eq("Actualizado SA")
      expect(record.data["trade_name"]).to eq("Actualizado")
      expect(event_bus).to have_received(:publish).with(instance_of(Identity::Events::SubjectContactDataUpdated))
    end

    it "incluye contact_entries en el evento cuando se proveen" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(
        Identity::Commands::RegisterSubject.new(
          aggregate_id: subject_id,
          tax_id: "20-22222222-2",
          legal_name: "Contact SA"
        )
      )

      cmd = Identity::Commands::UpdateSubjectContactData.new(
        aggregate_id: subject_id,
        contact_entries: [
          { type: "email", value: "a@b.com" },
          { "type" => "phone", "value" => "123456" }
        ]
      )
      handler.call(cmd)

      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.data["contact_entries"]).to eq([
        { "type" => "email", "value" => "a@b.com" },
        { "type" => "phone", "value" => "123456" }
      ])
    end

    it "lanza ArgumentError cuando el sujeto no existe" do
      cmd = Identity::Commands::UpdateSubjectContactData.new(
        aggregate_id: SecureRandom.uuid,
        legal_name: "X"
      )

      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Subject not found/)
    end
  end
end
