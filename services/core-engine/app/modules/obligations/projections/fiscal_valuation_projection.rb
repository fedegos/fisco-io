# frozen_string_literal: true

# Fisco.io - FiscalValuation projection
# Updates FiscalValuation read model from RevaluationRegistered events

module Obligations
  module Projections
    class FiscalValuationProjection < BaseProjection
      def handle_RevaluationRegistered(event)
        return unless FiscalValuation.table_exists?

        data = event.data
        obligation_id = data["obligation_id"] || event.aggregate_id
        year = data["year"].to_i
        value = data["value"].to_s.to_d

        FiscalValuation.find_or_initialize_by(obligation_id: obligation_id, year: year).tap do |v|
          v.value = value
          v.save!
        end
      end
    end
  end
end
