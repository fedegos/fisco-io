# frozen_string_literal: true

# Fisco.io - Core Engine
# Rack config

require_relative "config/environment"
run Rails.application
Rails.application.load_server
