# frozen_string_literal: true

# Fisco.io - Subject read model
# Modelo para la tabla subjects (proyección de eventos de identidad)

class SubjectReadModel < ActiveRecord::Base
  self.table_name = "subjects"
  self.primary_key = "subject_id"

  # subject_id (uuid PK), tax_id, legal_name, trade_name, status, registration_date, created_at, updated_at
  validates :subject_id, :tax_id, :legal_name, :status, :registration_date, presence: true
end
