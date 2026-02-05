# frozen_string_literal: true

# Fisco.io - ChangeSegment command
# Cambiar segmentación del sujeto / Change subject segmentation

module Identity
  module Commands
    class ChangeSegment < BaseCommand
      attr_reader :legal_segments, :administrative_segments

      def initialize(aggregate_id:, legal_segments: nil, administrative_segments: nil, **kwargs)
        super(aggregate_id: aggregate_id, **kwargs)
        @legal_segments = legal_segments
        @administrative_segments = administrative_segments
      end
    end
  end
end
