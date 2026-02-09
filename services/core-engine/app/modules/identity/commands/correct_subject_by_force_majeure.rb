# frozen_string_literal: true

# Fisco.io - CorrectSubjectByForceMajeure command (business: Corregir por fuerza mayor)
# Correct subject data by force majeure (operator_observations required)

module Identity
  module Commands
    class CorrectSubjectByForceMajeure < BaseCommand
      ALLOWED_FIELDS = %w[legal_name trade_name digital_domicile_id address_province address_locality address_line].freeze

      attr_reader :operator_observations, :attributes

      def initialize(aggregate_id:, operator_observations:, **opts)
        super(aggregate_id: aggregate_id, command_id: opts[:command_id], metadata: opts[:metadata] || {})
        @operator_observations = operator_observations.to_s.strip
        @attributes = opts.slice(*ALLOWED_FIELDS.map(&:to_sym)).transform_keys(&:to_s)
      end
    end
  end
end
