# frozen_string_literal: true

# Fisco.io - Carga explícita del event store al arrancar
# Evita "uninitialized constant EventStore::Repository" en db:seed.
# load() puede ejecutarse junto con Zeitwerk; silenciamos "method redefined" solo en esta carga.

Rails.application.config.after_initialize do
  base = Rails.root.join("app", "event_store")
  verbose = $VERBOSE
  $VERBOSE = nil
  load Rails.root.join("app", "event_store.rb").to_s
  load base.join("repository.rb").to_s
  load base.join("rehydrated_event.rb").to_s
  load base.join("event_bus.rb").to_s
ensure
  $VERBOSE = verbose
end
