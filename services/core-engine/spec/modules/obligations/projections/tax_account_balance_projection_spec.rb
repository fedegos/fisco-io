# frozen_string_literal: true

require "rails_helper"

RSpec.describe Obligations::Projections::TaxAccountBalanceProjection do
  let(:projection) { described_class.new }

  describe "#handle" do
    describe "handle_TaxObligationCreated / handle_ObligationOpened" do
      it "crea TaxAccountBalance cuando la tabla existe y no existía el obligation_id" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        subject_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "TaxObligationCreated",
          aggregate_id: obligation_id,
          data: {
            "obligation_id" => obligation_id,
            "primary_subject_id" => subject_id,
            "tax_type" => "inmobiliario",
            "external_id" => "12-10001",
            "status" => "open"
          }
        )

        expect { projection.handle(event) }.to change(TaxAccountBalance, :count).by(1)

        record = TaxAccountBalance.find_by(obligation_id: obligation_id)
        expect(record).to be_present
        expect(record.subject_id).to eq(subject_id)
        expect(record.tax_type).to eq("inmobiliario")
        expect(record.external_id).to eq("12-10001")
        expect(record.current_balance).to eq(0)
        expect(record.principal_balance).to eq(0)
      end

      it "es idempotente: no duplica si obligation_id ya existe" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        subject_id = SecureRandom.uuid
        TaxAccountBalance.create!(
          obligation_id: obligation_id,
          subject_id: subject_id,
          tax_type: "inmobiliario",
          current_balance: 0,
          principal_balance: 0,
          interest_balance: 0,
          updated_at: Time.current,
          version: 0
        )
        event = ProjectionEvent.new(
          event_type: "ObligationOpened",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "primary_subject_id" => subject_id, "tax_type" => "ib", "status" => "open" }
        )

        expect { projection.handle(event) }.not_to change(TaxAccountBalance, :count)
      end
    end

    describe "handle_TaxObligationUpdated" do
      it "actualiza external_id cuando el registro existe" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        TaxAccountBalance.create!(
          obligation_id: obligation_id,
          subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          current_balance: 0,
          principal_balance: 0,
          interest_balance: 0,
          updated_at: Time.current,
          version: 0
        )
        event = ProjectionEvent.new(
          event_type: "TaxObligationUpdated",
          aggregate_id: obligation_id,
          data: { "external_id" => "12-10002" }
        )

        projection.handle(event)

        record = TaxAccountBalance.find_by(obligation_id: obligation_id)
        expect(record.external_id).to eq("12-10002")
      end
    end

    describe "handle_TaxLiquidationCreated" do
      it "incrementa principal_balance y current_balance" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        TaxAccountBalance.create!(
          obligation_id: obligation_id,
          subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          current_balance: 0,
          principal_balance: 0,
          interest_balance: 0,
          updated_at: Time.current,
          version: 0
        )
        event = ProjectionEvent.new(
          event_type: "TaxLiquidationCreated",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "1500.50", "period" => "2024-01-15" }
        )

        projection.handle(event)

        record = TaxAccountBalance.find_by(obligation_id: obligation_id)
        expect(record.principal_balance).to eq(1500.50)
        expect(record.current_balance).to eq(1500.50)
        expect(record.last_liquidation_date).to eq(Date.parse("2024-01-15"))
        expect(record.version).to eq(1)
      end
    end

    describe "handle_PaymentReceived" do
      it "decrementa current_balance" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        TaxAccountBalance.create!(
          obligation_id: obligation_id,
          subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          current_balance: 2000,
          principal_balance: 2000,
          interest_balance: 0,
          updated_at: Time.current,
          version: 1
        )
        event = ProjectionEvent.new(
          event_type: "PaymentReceived",
          aggregate_id: obligation_id,
          data: { "obligation_id" => obligation_id, "amount" => "500" }
        )

        projection.handle(event)

        record = TaxAccountBalance.find_by(obligation_id: obligation_id)
        expect(record.current_balance).to eq(1500)
        expect(record.last_payment_date).to eq(Date.current)
        expect(record.version).to eq(2)
      end
    end

    describe "handle_TaxObligationClosed / handle_ObligationClosed" do
      it "actualiza status a closed y closed_at" do
        skip "tabla tax_account_balances no existe" unless TaxAccountBalance.table_exists?

        obligation_id = SecureRandom.uuid
        TaxAccountBalance.create!(
          obligation_id: obligation_id,
          subject_id: SecureRandom.uuid,
          tax_type: "inmobiliario",
          current_balance: 0,
          principal_balance: 0,
          interest_balance: 0,
          status: "open",
          updated_at: Time.current,
          version: 0
        )
        event = ProjectionEvent.new(
          event_type: "TaxObligationClosed",
          aggregate_id: obligation_id,
          data: { "closed_at" => Date.current.to_s }
        )

        projection.handle(event)

        record = TaxAccountBalance.find_by(obligation_id: obligation_id)
        expect(record.status).to eq("closed")
        expect(record.closed_at).to eq(Date.current)
      end
    end
  end
end
