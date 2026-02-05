# frozen_string_literal: true

# Fisco.io - Identity::Handlers::RegisterSubjectHandler specs

require "rails_helper"

RSpec.describe Identity::Handlers::RegisterSubjectHandler do
  let(:repository) { EventStore::Repository.new }
  let(:handler) { described_class.new(repository: repository) }

  describe "#call" do
    it "persiste SubjectRegistered y devuelve subject_id" do
      cmd = Identity::Commands::RegisterSubject.new(
        tax_id: "20-12345678-9",
        legal_name: "ACME SA",
        trade_name: "ACME"
      )

      result = handler.call(cmd)

      expect(result[:subject_id]).to be_a(String)
      expect(result[:subject_id].length).to eq(36)

      loaded = repository.load(result[:subject_id], Identity::Subject)
      expect(loaded).to be_a(Identity::Subject)
      expect(loaded.legal_name).to eq("ACME SA")
      expect(loaded.tax_id).to eq("20-12345678-9")
    end

    it "usa aggregate_id del comando si se provee" do
      subject_id = SecureRandom.uuid
      cmd = Identity::Commands::RegisterSubject.new(
        aggregate_id: subject_id,
        tax_id: "20-11111111-1",
        legal_name: "Test"
      )

      result = handler.call(cmd)

      expect(result[:subject_id]).to eq(subject_id)
      loaded = repository.load(subject_id, Identity::Subject)
      expect(loaded.subject_id).to eq(subject_id)
    end
  end
end
