# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Projections::AccountMovementsProjection do
  let(:projection) { described_class.new }

  describe "#handle" do
    describe "handle_TaxLiquidationCreated" do
      it "crea AccountMovement tipo liquidation (debit) cuando la tabla existe" do
        skip "tabla account_movements no existe" unless AccountMovement.table_exists?

        obligation_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "TaxLiquidationCreated",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "2500.00", "period" => "2024-02" }
        )

        expect { projection.handle(event) }.to change(AccountMovement, :count).by(1)

        mov = AccountMovement.last
        expect(mov.obligation_id).to eq(obligation_id)
        expect(mov.movement_type).to eq("liquidation")
        expect(mov.amount).to eq(2500)
        expect(mov.debit_credit).to eq("debit")
        expect(mov.period).to eq("2024-02")
      end

      it "no crea movimiento cuando amount es cero" do
        skip "tabla account_movements no existe" unless AccountMovement.table_exists?

        obligation_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "TaxLiquidationCreated",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "0", "period" => "2024-01" }
        )

        expect { projection.handle(event) }.not_to change(AccountMovement, :count)
      end
    end

    describe "handle_PaymentReceived" do
      it "crea AccountMovement tipo payment (credit)" do
        skip "tabla account_movements no existe" unless AccountMovement.table_exists?

        obligation_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "PaymentReceived",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "1000.00", "reference" => "REF-1" }
        )

        expect { projection.handle(event) }.to change(AccountMovement, :count).by(1)

        mov = AccountMovement.last
        expect(mov.movement_type).to eq("payment")
        expect(mov.debit_credit).to eq("credit")
        expect(mov.amount).to eq(1000)
        expect(mov.reference).to eq("REF-1")
      end
    end

    describe "handle_InterestAccrued" do
      it "crea AccountMovement tipo interest (debit)" do
        skip "tabla account_movements no existe" unless AccountMovement.table_exists?

        obligation_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "InterestAccrued",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "150.25", "period" => "2024-01" }
        )

        expect { projection.handle(event) }.to change(AccountMovement, :count).by(1)

        mov = AccountMovement.last
        expect(mov.movement_type).to eq("interest")
        expect(mov.debit_credit).to eq("debit")
        expect(mov.amount).to eq(150.25)
      end
    end
  end
end
