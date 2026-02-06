# frozen_string_literal: true

# Fisco.io - Core Engine
# Rutas: health, portal contribuyente, portal operadores (staff interno)

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root to: redirect("/contribuyente/obligaciones")

  namespace :contribuyente do
    get "obligaciones", to: "obligaciones#index"
  end

  namespace :operadores do
    root to: "dashboard#index", as: :root
  end
end
