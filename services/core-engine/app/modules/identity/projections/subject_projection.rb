# frozen_string_literal: true

# Fisco.io - Subject projection
# Proyección de sujetos (read model) / Subject read model projection

module Identity
  module Projections
    class SubjectProjection < BaseProjection
      def handle_SubjectRegistered(event)
        apply_subject_created(event.data)
      end

      def handle_SubjectEnrolled(event)
        apply_subject_created(event.data)
      end

      def handle_SubjectCeased(event)
        return unless SubjectReadModel.table_exists?

        record = SubjectReadModel.find_by(subject_id: event.aggregate_id)
        return unless record

        attrs = { status: "inactive" }
        attrs[:cessation_observations] = event.data["observations"] if event.data.is_a?(Hash) && event.data["observations"].present? && record.respond_to?(:cessation_observations=)
        record.update!(attrs)
      end

      def handle_SubjectUpdated(event)
        apply_subject_updated(event.data, event.aggregate_id)
      end

      def handle_SubjectContactDataUpdated(event)
        apply_subject_updated(event.data, event.aggregate_id)
      end

      def handle_SubjectDomicileChanged(event)
        apply_subject_updated(event.data, event.aggregate_id)
      end

      def handle_SubjectCorrectedByForceMajeure(event)
        apply_subject_updated(event.data, event.aggregate_id)
      end

      private

      def apply_subject_created(data)
        return unless SubjectReadModel.table_exists?
        return unless data.is_a?(Hash) && data["subject_id"].present?

        record = SubjectReadModel.find_or_initialize_by(subject_id: data["subject_id"])
        return if record.persisted?

        record.assign_attributes(
          subject_id: data["subject_id"],
          tax_id: data["tax_id"].to_s,
          legal_name: data["legal_name"].to_s,
          trade_name: data["trade_name"].to_s.presence,
          status: data["status"].presence || "active",
          registration_date: parse_date(data["registration_date"])
        )
        record.save!
      end

      def apply_subject_updated(data, aggregate_id)
        return unless SubjectReadModel.table_exists? && data.is_a?(Hash)

        record = SubjectReadModel.find_by(subject_id: aggregate_id)
        return unless record

        attrs = {}
        attrs[:legal_name] = data["legal_name"] if data.key?("legal_name")
        attrs[:trade_name] = data["trade_name"] if data.key?("trade_name")
        attrs[:address_province] = data["address_province"] if data.key?("address_province")
        attrs[:address_locality] = data["address_locality"] if data.key?("address_locality")
        attrs[:address_line] = data["address_line"] if data.key?("address_line")
        attrs[:digital_domicile_id] = data["digital_domicile_id"] if data.key?("digital_domicile_id")
        attrs[:contact_entries] = data["contact_entries"] if data.key?("contact_entries")
        record.update!(attrs) if attrs.any?
      end

      def parse_date(value)
        return nil if value.blank?
        return value if value.is_a?(Date)
        Date.parse(value.to_s)
      rescue ArgumentError
        nil
      end
    end
  end
end
