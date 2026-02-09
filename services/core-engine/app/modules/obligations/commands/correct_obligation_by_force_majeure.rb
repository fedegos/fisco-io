# frozen_string_literal: true

# Fisco.io - CorrectObligationByForceMajeure command (business: Corregir por fuerza mayor)

module Obligations
  module Commands
    class CorrectObligationByForceMajeure < BaseCommand
      ALLOWED_FIELDS = %w[external_id].freeze

      attr_reader :obligation_id, :operator_observations, :attributes

      def initialize(aggregate_id: nil, obligation_id: nil, operator_observations:, **opts)
        oid = aggregate_id || obligation_id
        super(aggregate_id: oid, command_id: opts[:command_id], metadata: opts[:metadata] || {})
        @obligation_id = oid
        @operator_observations = operator_observations.to_s.strip
        @attributes = opts.slice(*ALLOWED_FIELDS.map(&:to_sym)).transform_keys(&:to_s)
      end
    end
  end
end
