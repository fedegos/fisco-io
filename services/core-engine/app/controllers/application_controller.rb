# frozen_string_literal: true

# Fisco.io - Application controller
# Base para controladores con vistas (Rails + HTMX)

class ApplicationController < ActionController::Base
  # Por ahora sin autenticación; current_subject_id se puede inyectar por sesión más adelante
  helper_method :htmx_request?

  def htmx_request?
    request.headers["HX-Request"].present?
  end
end
