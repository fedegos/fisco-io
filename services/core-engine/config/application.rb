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

    # Incluir app/ para que Zeitwerk cargue event_store, modules, etc.
    config.autoload_paths << Rails.root.join("app")

    # Assets: precompilar application.css y application.js
    config.assets.enabled = true
    config.assets.version = "1.0"
  end
end
