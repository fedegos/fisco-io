# frozen_string_literal: true

# Fisco.io - Portal operadores: consultas (read models / proyecciones)
# Hub de acceso a proyecciones: sin listados embebidos (no escala). Enlaces a padrones (paginados/filtrados) y API.
module Operadores
  class ConsultasController < ApplicationController
    def index
      # No cargar muestras ni counts costosos a escala; la consulta real se hace en padrones con filtros y paginación
    end
  end
end
