# frozen_string_literal: true

# Fisco.io - Identity::Subject specs

require "spec_helper"
require "app/aggregates/base_aggregate"
require "app/modules/identity/subject"

RSpec.describe Identity::Subject do
  describe ".new" do
    it "inicializa con atributos opcionales" do
      subject_agg = described_class.new(subject_id: "sub-1", tax_id: "20-12345678-9", legal_name: "ACME")
      expect(subject_agg.subject_id).to eq("sub-1")
      expect(subject_agg.legal_name).to eq("ACME")
    end
  end

  describe "#apply_SubjectRegistered" do
    it "actualiza atributos desde el evento" do
      subject_agg = described_class.new(id: "agg-1")
      event = double(
        "event",
        data: {
          "subject_id" => "sub-1",
          "tax_id" => "20-12345678-9",
          "legal_name" => "ACME",
          "status" => "active",
          "registration_date" => "2024-01-01"
        },
        event_type: "SubjectRegistered",
        event_version: 1
      )
      subject_agg.apply(event)
      expect(subject_agg.subject_id).to eq("sub-1")
      expect(subject_agg.legal_name).to eq("ACME")
    end
  end
end
