# frozen_string_literal: true

# Fisco.io - Base Event
# Clase base para todos los eventos del dominio / Base class for all domain events
#
# Eventos son inmutables, nombre en pasado (Past Tense).
# Events are immutable, named in past tense.

class BaseEvent
  attr_reader :aggregate_id, :event_type, :event_version, :data, :metadata, :occurred_at

  def initialize(aggregate_id:, event_type:, event_version: 1, data: {}, metadata: {}, occurred_at: nil)
    @aggregate_id = aggregate_id
    @event_type = event_type
    @event_version = event_version
    @data = data.freeze
    @metadata = metadata.freeze
    @occurred_at = occurred_at || Time.now
  end

  # Serialización para persistencia en event store
  # Serialization for event store persistence
  def to_store
    {
      aggregate_id: aggregate_id,
      event_type: event_type,
      event_version: event_version,
      data: data,
      metadata: metadata,
      occurred_at: occurred_at.iso8601
    }
  end
end
