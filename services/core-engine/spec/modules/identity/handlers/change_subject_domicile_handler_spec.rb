# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Handlers::ChangeSubjectDomicileHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste SubjectDomicileChanged y actualiza domicilio en el agregado" do
      subject_id = SecureRandom.uuid
      Identity::Handlers::RegisterSubjectHandler.new(repository: repository).call(
        Identity::Commands::RegisterSubject.new(aggregate_id: subject_id, tax_id: "20-11111111-1", legal_name: "X")
      )

      cmd = Identity::Commands::ChangeSubjectDomicile.new(
        aggregate_id: subject_id,
        address_province: "Buenos Aires",
        address_locality: "La Plata",
        address_line: "Calle 1 123"
      )
      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)
      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded.address_province).to eq("Buenos Aires")
      expect(loaded.address_locality).to eq("La Plata")
      expect(loaded.address_line).to eq("Calle 1 123")
      record = EventRecord.where(aggregate_id: subject_id).order(:event_version).last
      expect(record.event_type).to eq("SubjectDomicileChanged")
      expect(event_bus).to have_received(:publish).with(instance_of(Identity::Events::SubjectDomicileChanged))
    end

    it "lanza ArgumentError cuando el sujeto no existe" do
      cmd = Identity::Commands::ChangeSubjectDomicile.new(aggregate_id: SecureRandom.uuid, address_province: "X")
      expect { handler.call(cmd) }.to raise_error(ArgumentError, /Subject not found/)
    end
  end
end
