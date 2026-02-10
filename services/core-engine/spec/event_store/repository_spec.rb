# frozen_string_literal: true

# Fisco.io - EventStore::Repository specs
# Roundtrip: append eventos, load agregado y verificar estado

require "rails_helper"

RSpec.describe EventStore::Repository do
  let(:repository) { described_class.new }

  describe "#append" do
    it "persiste un evento y asigna event_version y sequence_number" do
      aggregate_id = SecureRandom.uuid
      event = Identity::Events::SubjectRegistered.new(
        aggregate_id: aggregate_id,
        data: {
          "subject_id" => aggregate_id,
          "tax_id" => "20-12345678-9",
          "legal_name" => "ACME SA",
          "status" => "active",
          "registration_date" => "2024-01-01"
        }
      )

      expect { repository.append(aggregate_id, Identity::Subject.name, event) }.to change(EventRecord, :count).by(1)

      record = EventRecord.last
      expect(record.aggregate_id).to eq(aggregate_id)
      expect(record.aggregate_type).to eq("Identity::Subject")
      expect(record.event_type).to eq("SubjectRegistered")
      expect(record.event_version).to eq(1)
      expect(record.data["legal_name"]).to eq("ACME SA")
      expect(record.sequence_number).to be >= 1
    end
  end

  describe "#load" do
    it "reconstruye el agregado aplicando eventos en orden" do
      aggregate_id = SecureRandom.uuid
      event = Identity::Events::SubjectRegistered.new(
        aggregate_id: aggregate_id,
        data: {
          "subject_id" => aggregate_id,
          "tax_id" => "20-12345678-9",
          "legal_name" => "ACME SA",
          "trade_name" => "ACME",
          "status" => "active",
          "registration_date" => "2024-01-01"
        }
      )

      repository.append(aggregate_id, Identity::Subject.name, event)
      loaded = repository.load(aggregate_id, Identity::Subject)

      expect(loaded).to be_a(Identity::Subject)
      expect(loaded.subject_id).to eq(aggregate_id)
      expect(loaded.legal_name).to eq("ACME SA")
      expect(loaded.tax_id).to eq("20-12345678-9")
      expect(loaded.version).to eq(1)
    end

    it "retorna nil si no hay eventos para el aggregate_id" do
      loaded = repository.load(SecureRandom.uuid, Identity::Subject)
      expect(loaded).to be_nil
    end
  end

  describe "#load_up_to_version" do
    it "retorna nil si no hay eventos para el aggregate_id" do
      loaded = repository.load_up_to_version(SecureRandom.uuid, Obligations::TaxObligation, 1)
      expect(loaded).to be_nil
    end

    it "reconstruye el agregado solo hasta la versión indicada" do
      aggregate_id = SecureRandom.uuid
      subject_id = SecureRandom.uuid
      event1 = Obligations::Events::ObligationOpened.new(
        aggregate_id: aggregate_id,
        data: {
          "obligation_id" => aggregate_id,
          "primary_subject_id" => subject_id,
          "tax_type" => "inmobiliario",
          "role" => "contribuyente",
          "status" => "open",
          "opened_at" => Date.current.to_s
        }
      )
      repository.append(aggregate_id, Obligations::TaxObligation.name, event1)

      loaded = repository.load_up_to_version(aggregate_id, Obligations::TaxObligation, 1)
      expect(loaded).not_to be_nil
      expect(loaded.obligation_id).to eq(aggregate_id)
      expect(loaded.version).to eq(1)
    end
  end
end
