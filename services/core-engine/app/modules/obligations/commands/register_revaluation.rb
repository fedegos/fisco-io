# frozen_string_literal: true

# Fisco.io - RegisterRevaluation command (business: Revalúo)

module Obligations
  module Commands
    class RegisterRevaluation < BaseCommand
      attr_reader :obligation_id, :year, :value, :operator_observations

      def initialize(aggregate_id: nil, obligation_id:, year:, value:, operator_observations: nil, **kwargs)
        super(aggregate_id: (aggregate_id || obligation_id), **kwargs)
        @obligation_id = obligation_id
        @year = year.to_i
        @value = value.to_d
        @operator_observations = operator_observations.to_s.strip.presence
      end
    end
  end
end
