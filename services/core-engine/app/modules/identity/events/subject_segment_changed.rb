# frozen_string_literal: true

# Fisco.io - SubjectSegmentChanged event
# Segmentación del sujeto modificada / Subject segmentation changed

module Identity
  module Events
    class SubjectSegmentChanged < BaseEvent
      def initialize(aggregate_id:, data:, **kwargs)
        super(
          aggregate_id: aggregate_id,
          event_type: "SubjectSegmentChanged",
          data: data,
          **kwargs
        )
      end
    end
  end
end
