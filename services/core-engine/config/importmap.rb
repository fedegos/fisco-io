# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap
# Fisco.io - Hotwire (Turbo + Stimulus) con Importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "controllers", to: "controllers/index.js"
pin "controllers/application", to: "controllers/application.js"
pin_all_from "app/javascript/controllers", under: "controllers", to: "controllers"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
