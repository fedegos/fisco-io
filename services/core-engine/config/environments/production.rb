# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "no-cache, no-store" }

  # Assets: precompilados según app/assets/config/manifest.js (Sprockets + Importmap)
  config.assets.compile = false
  config.assets.digest = true
end
