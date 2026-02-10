# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Handlers::CeaseSubjectHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste SubjectCeased y devuelve subject_id cuando el sujeto existe" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(
        Identity::Commands::RegisterSubject.new(aggregate_id: subject_id, tax_id: "20-11111111-1", legal_name: "X")
      )

      cmd = Identity::Commands::CeaseSubject.new(aggregate_id: subject_id, observations: "Cierre voluntario")
      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)
      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded.status).to eq("inactive")
      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.event_type).to eq("SubjectCeased")
      expect(record.data["observations"]).to eq("Cierre voluntario")
      expect(event_bus).to have_received(:publish).with(instance_of(Identity::Events::SubjectCeased))
    end

    it "persiste sin observations (data con subject_id) cuando no se pasan" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(
        Identity::Commands::RegisterSubject.new(aggregate_id: subject_id, tax_id: "20-22222222-2", legal_name: "Y")
      )

      cmd = Identity::Commands::CeaseSubject.new(aggregate_id: subject_id)
      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)
      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.data["subject_id"]).to eq(subject_id)
    end

    it "lanza ArgumentError cuando el sujeto no existe" do
      cmd = Identity::Commands::CeaseSubject.new(aggregate_id: SecureRandom.uuid)
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Subject not found/)
    end
  end
end
