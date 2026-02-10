# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Projections::FiscalValuationProjection do
  let(:projection) { described_class.new }

  describe "#handle" do
    describe "handle_RevaluationRegistered" do
      it "crea o actualiza FiscalValuation cuando la tabla existe" do
        skip "tabla fiscal_valuations no existe" unless FiscalValuation.table_exists?

        obligation_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "RevaluationRegistered",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "year" => 2024, "value" => "1500000.00" }
        )

        expect { projection.handle(event) }.to change(FiscalValuation, :count).by(1)

        record = FiscalValuation.find_by(obligation_id: obligation_id, year: 2024)
        expect(record).to be_present
        expect(record.value).to eq(1_500_000)
      end

      it "actualiza value si ya existe la combinación obligation_id y year" do
        skip "tabla fiscal_valuations no existe" unless FiscalValuation.table_exists?

        obligation_id = SecureRandom.uuid
        FiscalValuation.create!(obligation_id: obligation_id, year: 2024, value: 1_000_000)
        event = ProjectionEvent.new(
          event_type: "RevaluationRegistered",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "year" => 2024, "value" => "2000000.00" }
        )

        expect { projection.handle(event) }.not_to change(FiscalValuation, :count)

        record = FiscalValuation.find_by(obligation_id: obligation_id, year: 2024)
        expect(record.value).to eq(2_000_000)
      end
    end
  end
end
