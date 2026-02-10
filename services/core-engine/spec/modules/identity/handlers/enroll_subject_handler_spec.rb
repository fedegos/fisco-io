# frozen_string_literal: true

# Fisco.io - Identity::Handlers::EnrollSubjectHandler specs

require "rails_helper"

RSpec.describe Identity::Handlers::EnrollSubjectHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste SubjectEnrolled y devuelve subject_id generado cuando no se provee aggregate_id" do
      cmd = Identity::Commands::EnrollSubject.new(
        tax_id: "20-88888888-8",
        legal_name: "Empadronado SA",
        trade_name: "Emp"
      )

      result = handler.call(cmd)

      expect(result[:subject_id]).to be_a(String)
      expect(result[:subject_id].length).to eq(36)

      loaded = repository.load(result[:subject_id], Identity::Subject)
      expect(loaded).to be_a(Identity::Subject)
      expect(loaded.legal_name).to eq("Empadronado SA")
      expect(loaded.tax_id).to eq("20-88888888-8")
      expect(loaded.trade_name).to eq("Emp")
      expect(loaded.status).to eq("active")

      record = EventRecord.where(aggregate_id: result[:subject_id]).order(:event_version).last
      expect(record.event_type).to eq("SubjectEnrolled")
      expect(record.data["legal_name"]).to eq("Empadronado SA")
      expect(event_bus).to have_received(:publish).with(instance_of(Identity::Events::SubjectEnrolled))
    end

    it "usa aggregate_id del comando cuando se provee" do
      subject_id = SecureRandom.uuid
      cmd = Identity::Commands::EnrollSubject.new(
        aggregate_id: subject_id,
        tax_id: "20-77777777-7",
        legal_name: "Con ID"
      )

      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)
      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded.subject_id).to eq(subject_id)
      expect(loaded.legal_name).to eq("Con ID")
    end
  end
end
