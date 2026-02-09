# frozen_string_literal: true

# Fisco.io - Subject projection
# Proyección de sujetos (read model) / Subjects projection (read model)

module Identity
  module Projections
    class SubjectProjection < BaseProjection
      def handle_SubjectRegistered(event)
        apply_subject_enrolled(event.data)
      end

      def handle_SubjectEnrolled(event)
        apply_subject_enrolled(event.data)
      end

      def handle_SubjectUpdated(event)
        apply_contact_data_updated(event)
      end

      def handle_SubjectContactDataUpdated(event)
        apply_contact_data_updated(event)
      end

      def handle_SubjectDomicileChanged(event)
        return unless SubjectReadModel.table_exists?

        rec = SubjectReadModel.find_by(subject_id: event.aggregate_id)
        return unless rec

        data = event.data
        attrs = { updated_at: Time.current }
        attrs[:address_province] = data["address_province"] if data.key?("address_province") && rec.respond_to?(:address_province=)
        attrs[:address_locality] = data["address_locality"] if data.key?("address_locality") && rec.respond_to?(:address_locality=)
        attrs[:address_line] = data["address_line"] if data.key?("address_line") && rec.respond_to?(:address_line=)
        attrs[:digital_domicile_id] = data["digital_domicile_id"] if data.key?("digital_domicile_id") && rec.respond_to?(:digital_domicile_id=)
        rec.update!(attrs)
      end

      def handle_SubjectDeactivated(event)
        apply_subject_ceased(event)
      end

      def handle_SubjectCeased(event)
        apply_subject_ceased(event)
      end

      def handle_SubjectCorrectedByForceMajeure(event)
        return unless SubjectReadModel.table_exists?

        rec = SubjectReadModel.find_by(subject_id: event.aggregate_id)
        return unless rec

        data = event.data
        attrs = { updated_at: Time.current }
        attrs[:legal_name] = data["legal_name"] if data.key?("legal_name")
        attrs[:trade_name] = data["trade_name"] if data.key?("trade_name")
        attrs[:address_province] = data["address_province"] if data.key?("address_province") && rec.respond_to?(:address_province=)
        attrs[:address_locality] = data["address_locality"] if data.key?("address_locality") && rec.respond_to?(:address_locality=)
        attrs[:address_line] = data["address_line"] if data.key?("address_line") && rec.respond_to?(:address_line=)
        attrs[:digital_domicile_id] = data["digital_domicile_id"] if data.key?("digital_domicile_id") && rec.respond_to?(:digital_domicile_id=)
        rec.update!(attrs) if attrs.size > 1
      end

      private

      def apply_subject_enrolled(data)
        return unless SubjectReadModel.table_exists?

        attrs = {
          subject_id: data["subject_id"],
          tax_id: data["tax_id"],
          legal_name: data["legal_name"],
          trade_name: data["trade_name"],
          status: data["status"] || "active",
          registration_date: data["registration_date"].is_a?(String) ? Date.parse(data["registration_date"]) : data["registration_date"],
          created_at: Time.current,
          updated_at: Time.current
        }
        attrs[:digital_domicile_id] = data["digital_domicile_id"] if data.key?("digital_domicile_id") && SubjectReadModel.column_names.include?("digital_domicile_id")
        SubjectReadModel.upsert(attrs, unique_by: :subject_id)
      end

      def apply_contact_data_updated(event)
        return unless SubjectReadModel.table_exists?

        rec = SubjectReadModel.find_by(subject_id: event.aggregate_id)
        return unless rec

        data = event.data
        attrs = { updated_at: Time.current }
        attrs[:legal_name] = data["legal_name"] if data.key?("legal_name")
        attrs[:trade_name] = data["trade_name"] if data.key?("trade_name")
        attrs[:contact_entries] = data["contact_entries"] if data.key?("contact_entries") && rec.respond_to?(:contact_entries=)
        rec.update!(attrs)
      end

      def apply_subject_ceased(event)
        return unless SubjectReadModel.table_exists?

        rec = SubjectReadModel.find_by(subject_id: event.aggregate_id)
        return unless rec

        rec.update!(status: "inactive", updated_at: Time.current)
      end

      public

      def handle_RepresentativeAuthorized(_event)
        # TODO: actualizar read model (representantes)
      end

      def handle_RepresentativeRevoked(_event)
        # TODO: actualizar read model (representantes)
      end

      def handle_SubjectSegmentChanged(_event)
        # TODO: actualizar read model (segmentos)
      end
    end
  end
end
