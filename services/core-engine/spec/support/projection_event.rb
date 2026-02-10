# frozen_string_literal: true

# Evento mínimo para specs de proyecciones (responde a event_type, data, aggregate_id)
ProjectionEvent = Struct.new(:event_type, :data, :aggregate_id, keyword_init: true) unless defined?(ProjectionEvent)
