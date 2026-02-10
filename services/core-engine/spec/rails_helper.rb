# frozen_string_literal: true

# Fisco.io - RSpec Rails
# Carga el entorno Rails para specs que usan ActiveRecord, etc.

require "spec_helper"

# Filtrar warnings de redefinición de métodos en gemas (vendor), no del código propio
module SuppressVendorMethodRedefined
  def warn(message, category: nil, **kwargs)
    if message.include?("vendor") && (message.include?("method redefined") || message.include?("previous definition"))
      return
    end
    super
  end
end
Warning.extend(SuppressVendorMethodRedefined)

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Event store y módulos se cargan vía initializer + Zeitwerk. No require_relative aquí.

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
