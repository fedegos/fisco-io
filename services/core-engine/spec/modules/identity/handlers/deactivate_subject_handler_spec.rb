# frozen_string_literal: true

# Fisco.io - Identity::Handlers::DeactivateSubjectHandler specs

require "rails_helper"

RSpec.describe Identity::Handlers::DeactivateSubjectHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste SubjectDeactivated y devuelve subject_id cuando el sujeto existe" do
      subject_id = SecureRandom.uuid
      register_cmd = Identity::Commands::RegisterSubject.new(
        aggregate_id: subject_id,
        tax_id: "20-12345678-9",
        legal_name: "ACME SA"
      )
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(register_cmd)

      cmd = Identity::Commands::DeactivateSubject.new(aggregate_id: subject_id)
      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)

      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded).to be_a(Identity::Subject)
      expect(loaded.status).to eq("inactive")

      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.event_type).to eq("SubjectDeactivated")
      expect(event_bus).to have_received(:publish).with(instance_of(Identity::Events::SubjectDeactivated))
    end

    it "lanza ArgumentError cuando el sujeto no existe" do
      cmd = Identity::Commands::DeactivateSubject.new(aggregate_id: SecureRandom.uuid)

      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Subject not found/)
    end
  end
end
