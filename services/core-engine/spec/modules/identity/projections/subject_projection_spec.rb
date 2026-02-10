# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identity::Projections::SubjectProjection do
  let(:projection) { described_class.new }

  describe "#handle" do
    describe "handle_SubjectRegistered / handle_SubjectEnrolled" do
      it "crea SubjectReadModel cuando la tabla existe y data tiene subject_id" do
        skip "tabla subjects no existe" unless SubjectReadModel.table_exists?

        subject_id = SecureRandom.uuid
        event = ProjectionEvent.new(
          event_type: "SubjectRegistered",
          aggregate_id: subject_id,
          data: {
            "subject_id" => subject_id,
            "tax_id" => "20-12345678-9",
            "legal_name" => "ACME SA",
            "trade_name" => "ACME",
            "status" => "active",
            "registration_date" => "2024-01-15"
          }
        )

        expect { projection.handle(event) }.to change(SubjectReadModel, :count).by(1)

        record = SubjectReadModel.find_by(subject_id: subject_id)
        expect(record).to be_present
        expect(record.tax_id).to eq("20-12345678-9")
        expect(record.legal_name).to eq("ACME SA")
        expect(record.trade_name).to eq("ACME")
        expect(record.status).to eq("active")
      end

      it "es idempotente: no duplica si el subject_id ya existe" do
        skip "tabla subjects no existe" unless SubjectReadModel.table_exists?

        subject_id = SecureRandom.uuid
        SubjectReadModel.create!(
          subject_id: subject_id,
          tax_id: "20-1",
          legal_name: "Existente",
          registration_date: Date.current
        )
        event = ProjectionEvent.new(
          event_type: "SubjectEnrolled",
          aggregate_id: subject_id,
          data: { "subject_id" => subject_id, "tax_id" => "20-2", "legal_name" => "Nuevo", "registration_date" => "2024-01-01" }
        )

        expect { projection.handle(event) }.not_to change(SubjectReadModel, :count)
        expect(SubjectReadModel.find_by(subject_id: subject_id).legal_name).to eq("Existente")
      end
    end

    describe "handle_SubjectCeased" do
      it "actualiza status a inactive cuando el registro existe" do
        skip "tabla subjects no existe" unless SubjectReadModel.table_exists?

        subject_id = SecureRandom.uuid
        SubjectReadModel.create!(
          subject_id: subject_id,
          tax_id: "20-1",
          legal_name: "X",
          registration_date: Date.current,
          status: "active"
        )
        event = ProjectionEvent.new(
          event_type: "SubjectCeased",
          aggregate_id: subject_id,
          data: { "observations" => "Cierre voluntario" }
        )

        projection.handle(event)

        record = SubjectReadModel.find_by(subject_id: subject_id)
        expect(record.status).to eq("inactive")
      end
    end

    describe "handle_SubjectUpdated / handle_SubjectContactDataUpdated" do
      it "actualiza legal_name y trade_name cuando el registro existe" do
        skip "tabla subjects no existe" unless SubjectReadModel.table_exists?

        subject_id = SecureRandom.uuid
        SubjectReadModel.create!(
          subject_id: subject_id,
          tax_id: "20-1",
          legal_name: "Original",
          registration_date: Date.current
        )
        event = ProjectionEvent.new(
          event_type: "SubjectUpdated",
          aggregate_id: subject_id,
          data: { "legal_name" => "Actualizado SA", "trade_name" => "Actualizado" }
        )

        projection.handle(event)

        record = SubjectReadModel.find_by(subject_id: subject_id)
        expect(record.legal_name).to eq("Actualizado SA")
        expect(record.trade_name).to eq("Actualizado")
      end
    end

    describe "handle_SubjectDomicileChanged" do
      it "actualiza address_province y address_locality cuando el registro existe" do
        skip "tabla subjects no existe" unless SubjectReadModel.table_exists?

        subject_id = SecureRandom.uuid
        SubjectReadModel.create!(
          subject_id: subject_id,
          tax_id: "20-1",
          legal_name: "X",
          registration_date: Date.current
        )
        event = ProjectionEvent.new(
          event_type: "SubjectDomicileChanged",
          aggregate_id: subject_id,
          data: { "address_province" => "Buenos Aires", "address_locality" => "La Plata", "address_line" => "Calle 1" }
        )

        projection.handle(event)

        record = SubjectReadModel.find_by(subject_id: subject_id)
        expect(record.address_province).to eq("Buenos Aires")
        expect(record.address_locality).to eq("La Plata")
        expect(record.address_line).to eq("Calle 1")
      end
    end
  end
end
