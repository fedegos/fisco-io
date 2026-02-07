# frozen_string_literal: true

# Fisco.io - Event Bus
# Publica eventos tras persistir en el event store. Log, luego dispara proyecciones; luego: Kafka.
# Vinculo: después de repository.append, el handler llama event_bus.publish(event).

module EventStore
  class EventBus
    DEFAULT_PROJECTORS = [
      Identity::Projections::SubjectProjection.new,
      Obligations::Projections::TaxAccountBalanceProjection.new,
      Obligations::Projections::AccountMovementsProjection.new
    ].freeze

    def initialize(projectors: nil)
      @projectors = projectors || DEFAULT_PROJECTORS
    end

    # Publica un evento a los consumidores (proyecciones, workers, otros servicios).
    # event: objeto que responde a event_type y data (BaseEvent).
    # Tras el log, recorre los projectors y llama projector.handle(event).
    def publish(event)
      payload = event.respond_to?(:to_store) ? event.to_store : event
      Rails.logger&.info("[EventBus] would publish: #{payload[:event_type]} aggregate_id=#{payload[:aggregate_id]}")

      @projectors.each do |projector|
        projector.handle(event)
      end
    end
  end
end
