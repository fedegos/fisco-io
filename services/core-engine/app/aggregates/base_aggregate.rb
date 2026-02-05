# frozen_string_literal: true

# Fisco.io - Base Aggregate
# Clase base para agregados / Base class for aggregates
#
# id + version; apply(event) delega a apply_<event_type>.
# Subclases definen apply_* para cada evento que aplican.

class BaseAggregate
  attr_reader :id, :version

  def initialize(id: nil, version: 0)
    @id = id
    @version = version
  end

  # Aplica un evento y actualiza versión / Applies event and increments version
  def apply(event)
    handler = :"apply_#{event.event_type}"
    send(handler, event) if respond_to?(handler, true)
    @version = event.event_version if event.respond_to?(:event_version)
    self
  end
end
