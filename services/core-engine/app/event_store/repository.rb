# frozen_string_literal: true

# Fisco.io - Event Store Repository
# Persistencia y carga de eventos (append-only). Fuente de verdad en PostgreSQL.
# Tras append se puede publicar a Kafka vía EventBus (ver ApplicationService o handlers).

module EventStore
  class Repository
    class AppendError < StandardError; end

    # Persiste un evento en la tabla events. Asigna event_version y sequence_number.
    # event debe responder a to_store (BaseEvent).
    def append(aggregate_id, aggregate_type, event)
      store = event.to_store
      next_version = next_event_version(aggregate_id)
      next_sequence = next_sequence_number

      EventRecord.create!(
        aggregate_id: aggregate_id,
        aggregate_type: aggregate_type,
        event_type: store[:event_type],
        event_version: next_version,
        data: store[:data],
        metadata: store[:metadata] || {},
        sequence_number: next_sequence
      )
    rescue ActiveRecord::RecordInvalid => e
      raise AppendError, "Event store append failed: #{e.message}"
    end

    # Reconstruye el agregado cargando todos sus eventos por aggregate_id.
    # aggregate_class: clase del agregado (ej. Identity::Subject).
    def load(aggregate_id, aggregate_class)
      load_up_to_version(aggregate_id, aggregate_class, nil)
    end

    # Reconstruye el agregado aplicando solo eventos con event_version <= up_to_version.
    # up_to_version nil = todos. Útil para auditoría (snapshot en un punto del tiempo).
    def load_up_to_version(aggregate_id, aggregate_class, up_to_version)
      scope = EventRecord
        .where(aggregate_id: aggregate_id, aggregate_type: aggregate_class.name)
        .order(:event_version)
      scope = scope.where("event_version <= ?", up_to_version) if up_to_version.present?
      records = scope.to_a

      return nil if records.empty?

      aggregate = aggregate_class.new(id: aggregate_id, version: 0)
      records.each do |record|
        rehydrated = RehydratedEvent.from_record(record)
        aggregate.apply(rehydrated)
      end
      aggregate
    end

    private

    def next_event_version(aggregate_id)
      max = EventRecord.where(aggregate_id: aggregate_id).maximum(:event_version)
      (max || 0) + 1
    end

    def next_sequence_number
      max = EventRecord.maximum(:sequence_number)
      (max || 0) + 1
    end
  end
end
