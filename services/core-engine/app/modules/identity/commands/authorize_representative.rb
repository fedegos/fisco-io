# frozen_string_literal: true

# Fisco.io - AuthorizeRepresentative command
# Autorizar representante / Authorize representative

module Identity
  module Commands
    class AuthorizeRepresentative < BaseCommand
      attr_reader :representative_id, :scope

      def initialize(aggregate_id:, representative_id:, scope: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @representative_id = representative_id
        @scope = scope
      end
    end
  end
end
