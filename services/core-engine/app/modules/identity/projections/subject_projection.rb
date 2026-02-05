# frozen_string_literal: true

# Fisco.io - Subject projection
# Proyección de sujetos (read model) / Subjects projection (read model)
# Handlers vacíos en scaffolding / Empty handlers in scaffolding

module Identity
  module Projections
    class SubjectProjection < BaseProjection
      def handle_SubjectRegistered(_event)
        # TODO: actualizar read model
      end

      def handle_RepresentativeAuthorized(_event)
        # TODO: actualizar read model
      end

      def handle_RepresentativeRevoked(_event)
        # TODO: actualizar read model
      end

      def handle_SubjectSegmentChanged(_event)
        # TODO: actualizar read model
      end
    end
  end
end
