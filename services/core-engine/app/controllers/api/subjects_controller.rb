# frozen_string_literal: true

# Fisco.io - API: sujetos (consulta y comando RegisterSubject)

module Api
  class SubjectsController < Api::BaseController
    def index
      records = SubjectReadModel.order(created_at: :desc)
      render json: records.map { |r| subject_json(r) }
    end

    def create
      cmd = Identity::Commands::RegisterSubject.new(
        tax_id: params.require(:tax_id),
        legal_name: params.require(:legal_name),
        trade_name: params[:trade_name]
      )
      result = Identity::Handlers::RegisterSubjectHandler.new.call(cmd)
      render json: { subject_id: result[:subject_id] }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    private

    def subject_json(record)
      {
        subject_id: record.subject_id,
        tax_id: record.tax_id,
        legal_name: record.legal_name,
        trade_name: record.trade_name,
        status: record.status,
        registration_date: record.registration_date&.to_s
      }
    end
  end
end
