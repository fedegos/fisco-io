# frozen_string_literal: true

# Fisco.io - Portal operadores: consultas (read models / proyecciones)
# Resumen de proyecciones disponibles y acceso a listados

module Operadores
  class ConsultasController < ApplicationController
    def index
      @subjects_count = SubjectReadModel.count
      @obligations_count = TaxAccountBalance.count
      @subjects_sample = SubjectReadModel.order(created_at: :desc).limit(5)
      @obligations_sample = TaxAccountBalance.order(updated_at: :desc).limit(5)
    end
  end
end
