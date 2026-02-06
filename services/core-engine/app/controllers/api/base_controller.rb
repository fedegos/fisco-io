# frozen_string_literal: true

# Fisco.io - API base controller
# Respuestas JSON; sin layout. Autenticación/authorization luego.

module Api
  class BaseController < ActionController::Base
    skip_before_action :verify_authenticity_token, if: :api_request?
    before_action :set_default_format

    private

    def api_request?
      request.path.start_with?("/api")
    end

    def set_default_format
      request.format = :json if request.format == :html
    end

    def render_error(message, status: :unprocessable_entity)
      render json: { error: message }, status: status
    end
  end
end
