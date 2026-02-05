# frozen_string_literal: true

# Fisco.io - Base Projection
# Clase base para proyecciones (read models) / Base class for projections
#
# handle(event) delega por event_type; idempotencia por event_id/posición (scaffolding).
# Projections consume events to build optimized read models.

class BaseProjection
  # Procesa un evento; subclases implementan handle_<event_type>
  # Processes an event; subclasses implement handle_<event_type>
  def handle(event)
    handler = :"handle_#{event.event_type}"
    send(handler, event) if respond_to?(handler, true)
    self
  end
end
