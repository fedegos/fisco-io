# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "no-cache" }

  # Permitir cualquier host en tests (Capybara usa www.example.com)
  config.hosts.clear
end
