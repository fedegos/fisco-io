# frozen_string_literal: true

# Fisco.io - UpdateSubjectContactData command (business: Actualizar datos de contacto)
# legal_name, trade_name + contact_entries (array of { type, value })

module Identity
  module Commands
    class UpdateSubjectContactData < BaseCommand
      ALLOWED_CONTACT_TYPES = %w[email phone mobile].freeze

      attr_reader :legal_name, :trade_name, :contact_entries

      def initialize(aggregate_id:, legal_name: nil, trade_name: nil, contact_entries: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @legal_name = legal_name.to_s.strip.presence
        @trade_name = trade_name.to_s.strip.presence
        @contact_entries = normalize_contact_entries(contact_entries)
      end

      private

      def normalize_contact_entries(entries)
        return [] if entries.blank?
        Array(entries).filter_map do |entry|
          next if entry.blank?
          type = (entry[:type] || entry["type"]).to_s.strip.downcase.presence
          value = (entry[:value] || entry["value"]).to_s.strip.presence
          next if type.blank? || value.blank?
          next unless ALLOWED_CONTACT_TYPES.include?(type)
          { "type" => type, "value" => value }
        end
      end
    end
  end
end
