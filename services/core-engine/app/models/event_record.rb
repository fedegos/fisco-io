# frozen_string_literal: true

# Fisco.io - EventRecord
# Modelo ActiveRecord para la tabla events (event store)
# Solo persistencia; no exponer como API de dominio

class EventRecord < ActiveRecord::Base
  self.table_name = "events"
  self.primary_key = "id"

  # id (uuid), aggregate_id, aggregate_type, event_type, event_version,
  # data (jsonb), metadata (jsonb), created_at, updated_at, sequence_number

  validates :aggregate_id, :aggregate_type, :event_type, :event_version, :data, presence: true
  validates :event_version, numericality: { only_integer: true, greater_than: 0 }
end
