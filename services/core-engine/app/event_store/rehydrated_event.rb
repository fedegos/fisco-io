# frozen_string_literal: true

# Fisco.io - RehydratedEvent
# Objeto evento reconstruido desde el event store para aplicar al agregado
# Responde a event_type, data, event_version, aggregate_id (para apply)

module EventStore
  RehydratedEvent = Struct.new(:event_type, :data, :event_version, :aggregate_id, keyword_init: true) do
    def self.from_record(record)
      new(
        event_type: record.event_type,
        data: record.data.is_a?(Hash) ? record.data : {},
        event_version: record.event_version,
        aggregate_id: record.aggregate_id
      )
    end
  end
end
