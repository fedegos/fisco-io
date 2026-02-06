# frozen_string_literal: true

# Fisco.io - Carga explícita del event store al arrancar
# Evita "uninitialized constant EventStore::Repository" en db:seed.
# Usamos load() con ruta absoluta para no depender del autoload de Zeitwerk.

Rails.application.config.after_initialize do
  base = Rails.root.join("app", "event_store")
  load base.join("..", "event_store.rb").to_s   # app/event_store.rb
  load base.join("repository.rb").to_s
  load base.join("rehydrated_event.rb").to_s
  load base.join("event_bus.rb").to_s
end
