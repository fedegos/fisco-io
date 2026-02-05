# frozen_string_literal: true

# Fisco.io - Core Engine
# API routes (scaffolding)

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
end
