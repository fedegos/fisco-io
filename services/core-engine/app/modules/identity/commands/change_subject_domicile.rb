# frozen_string_literal: true

# Fisco.io - ChangeSubjectDomicile command (business: Mudar domicilio físico principal)

module Identity
  module Commands
    class ChangeSubjectDomicile < BaseCommand
      attr_reader :address_province, :address_locality, :address_line, :digital_domicile_id

      def initialize(aggregate_id:, address_province: nil, address_locality: nil, address_line: nil, digital_domicile_id: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @address_province = address_province.to_s.strip.presence
        @address_locality = address_locality.to_s.strip.presence
        @address_line = address_line.to_s.strip.presence
        @digital_domicile_id = digital_domicile_id.to_s.strip.presence
      end
    end
  end
end
