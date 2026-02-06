# frozen_string_literal: true

# Fisco.io - RSpec Rails
# Carga el entorno Rails para specs que usan ActiveRecord, etc.

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Cargar event store explícitamente (Zeitwerk en test puede no autoloadear bajo app/event_store)
require_relative "../app/event_store/repository"
require_relative "../app/event_store/event_bus"
require_relative "../app/event_store/rehydrated_event"

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
