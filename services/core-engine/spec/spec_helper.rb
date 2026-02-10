# frozen_string_literal: true

# Fisco.io - RSpec configuration
# SimpleCov debe cargarse antes que cualquier código de la aplicación (si está instalado)
begin
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "/spec/"
    add_filter "/config/"
    add_filter "/bin/"
    add_filter "/db/"
    add_filter "/vendor/"
    coverage_dir "coverage"
    minimum_coverage 0
  end
rescue LoadError
  # simplecov no instalado: bundle install en grupo test
end

APP_ROOT = File.expand_path("..", __dir__)
$LOAD_PATH.unshift(APP_ROOT) unless $LOAD_PATH.include?(APP_ROOT)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
