# frozen_string_literal: true

# Fisco.io - Subject projection
# Proyección de sujetos (read model) / Subjects projection (read model)

module Identity
  module Projections
    class SubjectProjection < BaseProjection
      def handle_SubjectRegistered(event)
        return unless SubjectReadModel.table_exists?

        data = event.data
        SubjectReadModel.upsert(
          {
            subject_id: data["subject_id"],
            tax_id: data["tax_id"],
            legal_name: data["legal_name"],
            trade_name: data["trade_name"],
            status: data["status"] || "active",
            registration_date: data["registration_date"].is_a?(String) ? Date.parse(data["registration_date"]) : data["registration_date"],
            created_at: Time.current,
            updated_at: Time.current
          },
          unique_by: :subject_id
        )
      end

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
