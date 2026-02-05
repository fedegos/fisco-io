# frozen_string_literal: true

# Fisco.io - Event Bus
# Publica eventos tras persistir en el event store. Hoy: no-op / log; luego: Kafka.
# Vinculo: después de repository.append, el handler llama event_bus.publish(event).

module EventStore
  class EventBus
    # Publica un evento a los consumidores (proyecciones, workers, otros servicios).
    # event: objeto que responde a to_store (BaseEvent).
    # Por ahora no-op; cuando Kafka esté configurado, serializar y enviar al topic según event_type/channel.
    def publish(event)
      payload = event.respond_to?(:to_store) ? event.to_store : event
      # TODO: publicar a Kafka según docs/asyncapi (ej. identity/subject, obligations/obligation)
      Rails.logger&.info("[EventBus] would publish: #{payload[:event_type]} aggregate_id=#{payload[:aggregate_id]}")
    end
  end
end
