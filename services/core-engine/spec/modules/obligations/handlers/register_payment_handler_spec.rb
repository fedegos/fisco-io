require "rails_helper"

RSpec.describe Obligations::Handlers::RegisterPaymentHandler do
  let(:repository) { EventStore::Repository.new }
  let(:event_bus) { instance_double(EventStore::EventBus, publish: true) }
  let(:handler) { described_class.new(repository: repository, event_bus: event_bus) }

  describe "#call" do
    it "persiste PaymentReceived con amount y allocations y devuelve el resultado" do
      obligation_id = SecureRandom.uuid
      amount = BigDecimal("500.00")
      allocations = [
        { "period" => "2024-01", "amount" => "300.00" },
        { "period" => "2024-02", "amount" => "200.00" }
      ]

      cmd = Obligations::Commands::RegisterPayment.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        amount: amount,
        allocations: allocations
      )

      result = handler.call(cmd)

      expect(result[:obligation_id]).to eq(obligation_id)
      expect(result[:amount]).to eq(amount)

      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record).not_to be_nil
      expect(record.aggregate_type).to eq("Obligations::TaxObligation")
      expect(record.event_type).to eq("PaymentReceived")
      expect(record.data["obligation_id"]).to eq(obligation_id)
      expect(record.data["amount"]).to eq(amount.to_s)
      expect(record.data["allocations"]).to eq(allocations)

      expect(event_bus).to have_received(:publish).with(instance_of(Obligations::Events::PaymentReceived))
    end

    it "no incluye allocations en el evento cuando es nil" do
      obligation_id = SecureRandom.uuid
      amount = BigDecimal("250.00")

      cmd = Obligations::Commands::RegisterPayment.new(
        aggregate_id: obligation_id,
        obligation_id: obligation_id,
        amount: amount
      )

      handler.call(cmd)

      record = EventRecord.where(aggregate_id: obligation_id).order(:event_version).last
      expect(record).not_to be_nil
      expect(record.data["amount"]).to eq(amount.to_s)
      expect(record.data).not_to have_key("allocations")
    end
  end
end

