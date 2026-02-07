# frozen_string_literal: true

# Fisco.io - Portal operadores: detalle de obligación (cuenta corriente y sujetos responsables)

module Operadores
  class ObligacionesController < ApplicationController
    def show
      @obligacion = TaxAccountBalance.find_by!(obligation_id: params[:id])
      @movimientos = AccountMovement.where(obligation_id: params[:id]).order(movement_date: :asc, created_at: :asc)
      # Sujeto(s) responsable(s): por ahora el subject_id de la proyección; luego ampliar con cotitulares
      @sujetos_responsables = load_responsible_subjects(@obligacion)
    rescue ActiveRecord::RecordNotFound
      redirect_to operadores_consultas_path, alert: "Obligación no encontrada"
    end

    private

    def load_responsible_subjects(obligation)
      subject = SubjectReadModel.find_by(subject_id: obligation.subject_id)
      return [] unless subject

      [{ subject_id: subject.subject_id, tax_id: subject.tax_id, legal_name: subject.legal_name, role: "titular" }]
    end
  end
end
