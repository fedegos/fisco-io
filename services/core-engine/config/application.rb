# frozen_string_literal: true

# Fisco.io - Core Engine
# Rails application configuration

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "importmap-rails"

Bundler.require(*Rails.groups)

module CoreEngine
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = false

    # Agregar app/ como raíz de autoload para que Zeitwerk cargue:
    # - app/event_store.rb → EventStore
    # - app/event_store/repository.rb → EventStore::Repository
    # - app/modules/* → módulos de dominio
    config.autoload_paths << Rails.root.join("app").to_s

    # Assets: precompilar application.css y application.js
    config.assets.enabled = true
    config.assets.version = "1.0"
  end
end
