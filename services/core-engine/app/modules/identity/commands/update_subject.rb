# frozen_string_literal: true

# Fisco.io - UpdateSubject command
# Actualizar datos editables de un sujeto / Update editable subject data

module Identity
  module Commands
    class UpdateSubject < BaseCommand
      attr_reader :legal_name, :trade_name

      def initialize(aggregate_id:, legal_name:, trade_name: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @legal_name = legal_name
        @trade_name = trade_name
      end
    end
  end
end
