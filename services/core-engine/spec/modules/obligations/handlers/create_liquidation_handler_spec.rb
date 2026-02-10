require "rails_helper"

RSpec.describe Obligations::Handlers::CreateLiquidationHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste TaxLiquidationCreated y devuelve obligación, período y monto" do
      obligation_id = SecureRandom.uuid
      period = "2024-01"
      amount = BigDecimal("1000.50")

      cmd = Obligations::Commands::CreateLiquidation.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        period: period,
        amount: amount
      )

      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      expect(result[:period]).to eq(period)
      expect(result[:amount]).to eq(amount)

      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record).not_to be_nil
      expect(record.aggregate_type).to eq("Obligations::TaxObligation")
      expect(record.event_type).to eq("TaxLiquidationCreated")
      expect(record.data["obligation_id"]).to eq(obligation_id)
      expect(record.data["period"]).to eq(period)
      expect(record.data["amount"]).to eq(amount.to_s)

      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::TaxLiquidationCreated))
    end
  end
end

