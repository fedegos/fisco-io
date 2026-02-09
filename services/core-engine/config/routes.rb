# frozen_string_literal: true

# Fisco.io - Core Engine
# Rutas: health, portal contribuyente, portal operadores (staff interno)

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root to: redirect("/contribuyente/obligaciones")

  namespace :contribuyente do
    get "obligaciones", to: "obligaciones#index"
    get "obligaciones/:id", to: "obligaciones#show", as: :obligacion
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
    get "configuracion/inmobiliario/precalculo", to: "precalculos#index", as: :precalculos
    get "configuracion/inmobiliario/precalculo/:year", to: "precalculos#show", as: :precalculo_year
    post "configuracion/inmobiliario/precalculo/generar", to: "precalculos#generar", as: :generar_precalculo
    patch "configuracion/inmobiliario/precalculo/:year/validar", to: "precalculos#validar", as: :validar_precalculo
    delete "configuracion/inmobiliario/precalculo/:year", to: "precalculos#revertir", as: :revertir_precalculo
    patch "configuracion/inmobiliario/precalculo/:year/producir", to: "precalculos#producir", as: :producir_precalculo
    get "configuracion/inmobiliario/:year/brackets", to: "inmobiliario_brackets#index", as: :inmobiliario_brackets
    patch "configuracion/inmobiliario/:year/brackets", to: "inmobiliario_brackets#update_all"
    get "configuracion/inmobiliario/:year/brackets/new", to: "inmobiliario_brackets#new", as: :new_inmobiliario_bracket
    post "configuracion/inmobiliario/:year/brackets", to: "inmobiliario_brackets#create"
    get "obligaciones/:id", to: "obligaciones#show", as: :obligacion
    get "padron/sujetos", to: "padron_sujetos#index", as: :padron_sujetos
    get "padron/sujetos/new", to: "padron_sujetos#new", as: :new_padron_sujeto
    post "padron/sujetos", to: "padron_sujetos#create"
    get "padron/sujetos/:id", to: "padron_sujetos#show", as: :padron_sujeto
    get "padron/sujetos/:id/edit", to: "padron_sujetos#edit", as: :edit_padron_sujeto
    patch "padron/sujetos/:id", to: "padron_sujetos#update", as: :update_padron_sujeto
    get "padron/sujetos/:id/domicilio", to: "padron_sujetos#domicilio", as: :domicilio_padron_sujeto
    patch "padron/sujetos/:id/domicilio", to: "padron_sujetos#domicilio_update"
    patch "padron/sujetos/:id/cesar", to: "padron_sujetos#desactivar", as: :cesar_padron_sujeto
    get "padron/sujetos/:id/corregir_fuerza_mayor", to: "padron_sujetos#corregir_fuerza_mayor", as: :corregir_fuerza_mayor_padron_sujeto
    patch "padron/sujetos/:id/corregir_fuerza_mayor", to: "padron_sujetos#corregir_fuerza_mayor_update"
    patch "padron/sujetos/:id/desactivar", to: "padron_sujetos#desactivar", as: :desactivar_padron_sujeto
    get "padron/sujetos/export", to: "padron_sujetos#export", as: :padron_sujetos_export
    post "padron/sujetos/import", to: "padron_sujetos#import", as: :padron_sujetos_import
    get "padron/objetos", to: "padron_objetos#index", as: :padron_objetos
    get "padron/objetos/export", to: "padron_objetos#export", as: :padron_objetos_export
    post "padron/objetos/import", to: "padron_objetos#import", as: :padron_objetos_import
    get "padron/objetos/new", to: "padron_objetos#new", as: :new_padron_objeto
    post "padron/objetos", to: "padron_objetos#create"
    get "padron/objetos/:id", to: "padron_objetos#show", as: :padron_objeto
    get "padron/objetos/:id/edit", to: "padron_objetos#edit", as: :edit_padron_objeto
    patch "padron/objetos/:id", to: "padron_objetos#update"
    patch "padron/objetos/:id/cerrar", to: "padron_objetos#cerrar", as: :cerrar_padron_objeto
    get "padron/objetos/:id/corregir_fuerza_mayor", to: "padron_objetos#corregir_fuerza_mayor", as: :corregir_fuerza_mayor_padron_objeto
    patch "padron/objetos/:id/corregir_fuerza_mayor", to: "padron_objetos#corregir_fuerza_mayor_update"
    post "padron/objetos/:id/valuaciones", to: "padron_objetos#create_valuacion", as: :padron_objeto_valuaciones
    patch "padron/objetos/:id/valuaciones/:year", to: "padron_objetos#update_valuacion", as: :padron_objeto_valuacion
  end

  namespace :api, defaults: { format: :json } do
    resources :subjects, only: [:index, :create]
    get "sujetos", to: "sujetos#index"
    post "sujetos/empadronar", to: "sujetos#empadronar"
    patch "sujetos/:id/datos_contacto", to: "sujetos#datos_contacto"
    patch "sujetos/:id/domicilio", to: "sujetos#domicilio"
    patch "sujetos/:id/cesar", to: "sujetos#cesar"
    patch "sujetos/:id/corregir_fuerza_mayor", to: "sujetos#corregir_fuerza_mayor"
    get "partidas", to: "partidas#index"
    post "partidas/abrir", to: "partidas#abrir"
    post "partidas/:id/revaluos", to: "partidas#revaluos"
    patch "partidas/:id/cerrar", to: "partidas#cerrar"
    patch "partidas/:id/corregir_fuerza_mayor", to: "partidas#corregir_fuerza_mayor"
    resources :obligations, only: [:index, :show, :create] do
      get "movements", on: :member, to: "movements#index"
      post "liquidations", on: :member, to: "liquidations#create"
      post "payments", on: :member, to: "payments#create"
      post "determine", on: :member, to: "determinations#create"
    end
  end
end
