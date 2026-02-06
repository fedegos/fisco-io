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
    get "eventos", to: "eventos#index"
    get "comandos", to: "comandos#index"
    get "consultas", to: "consultas#index"
    get "configuracion/inmobiliario", to: "inmobiliario_configs#index", as: :inmobiliario_configs
    get "configuracion/inmobiliario/new", to: "inmobiliario_configs#new"
    post "configuracion/inmobiliario", to: "inmobiliario_configs#create"
    get "configuracion/inmobiliario/:id/edit", to: "inmobiliario_configs#edit", as: :edit_inmobiliario_config
    patch "configuracion/inmobiliario/:id", to: "inmobiliario_configs#update", as: :inmobiliario_config
    get "configuracion/inmobiliario/:year/brackets", to: "inmobiliario_brackets#index", as: :inmobiliario_brackets
    get "configuracion/inmobiliario/:year/brackets/new", to: "inmobiliario_brackets#new", as: :new_inmobiliario_bracket
    post "configuracion/inmobiliario/:year/brackets", to: "inmobiliario_brackets#create"
  end

  namespace :api, defaults: { format: :json } do
    resources :subjects, only: [:index, :create]
    resources :obligations, only: [:index, :show, :create] do
      post "liquidations", on: :member, to: "liquidations#create"
      post "payments", on: :member, to: "payments#create"
      post "determine", on: :member, to: "determinations#create"
    end
  end
end
