# frozen_string_literal: true

# Fisco.io - Capybara para system specs (rack_test, sin navegador)

require "capybara/rspec"

Capybara.app = Rails.application

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :rack_test
Capybara.server = :puma
Capybara.default_max_wait_time = 2

RSpec.configure do |config|
  config.include Capybara::DSL, type: :system
  config.before(type: :system) { driven_by :rack_test }
end
