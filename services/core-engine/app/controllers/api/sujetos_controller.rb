# frozen_string_literal: true

# Fisco.io - API: sujetos (operaciones de negocio nombradas)
# Endpoints: empadronar, datos_contacto, domicilio, cesar, corregir_fuerza_mayor

module Api
  class SujetosController < Api::BaseController
    def index
      records = SubjectReadModel.order(created_at: :desc)
      render json: records.map { |r| subject_json(r) }
    end

    def empadronar
      cmd = Identity::Commands::EnrollSubject.new(
        tax_id: params.require(:tax_id),
        legal_name: params.require(:legal_name),
        trade_name: params[:trade_name]
      )
      result = Identity::Handlers::EnrollSubjectHandler.new.call(cmd)
      render json: { subject_id: result[:subject_id] }, status: :created
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    def datos_contacto
      permitted = params.permit(:legal_name, :trade_name, contact_entries: [:type, :value])
      raw_entries = permitted[:contact_entries]
      raw_entries = raw_entries.values if raw_entries.is_a?(Hash)
      contact_entries = Array(raw_entries).filter_map do |ce|
        next unless ce.is_a?(ActionController::Parameters) || ce.respond_to?(:to_h)
        h = ce.to_h.symbolize_keys
        { type: h[:type].to_s.strip, value: h[:value].to_s.strip } if h[:type].present? && h[:value].present?
      end
      cmd = Identity::Commands::UpdateSubjectContactData.new(
        aggregate_id: params[:id],
        legal_name: permitted[:legal_name].to_s.presence,
        trade_name: permitted[:trade_name].to_s.presence,
        contact_entries: contact_entries
      )
      Identity::Handlers::UpdateSubjectContactDataHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    def domicilio
      cmd = Identity::Commands::ChangeSubjectDomicile.new(
        aggregate_id: params[:id],
        address_province: params[:address_province],
        address_locality: params[:address_locality],
        address_line: params[:address_line],
        digital_domicile_id: params[:digital_domicile_id]
      )
      Identity::Handlers::ChangeSubjectDomicileHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError => e
      render_error(e.message)
    end

    def cesar
      cmd = Identity::Commands::CeaseSubject.new(aggregate_id: params[:id])
      Identity::Handlers::CeaseSubjectHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError => e
      render_error(e.message)
    end

    def corregir_fuerza_mayor
      obs = params.require(:operator_observations).to_s.strip
      raise ArgumentError, "operator_observations is required" if obs.blank?

      attrs = params.permit(:legal_name, :trade_name, :digital_domicile_id, :address_province, :address_locality, :address_line).to_h.compact_blank
      raise ArgumentError, "at least one attribute must be provided" if attrs.blank?

      cmd = Identity::Commands::CorrectSubjectByForceMajeure.new(
        aggregate_id: params[:id],
        operator_observations: obs,
        **attrs.symbolize_keys
      )
      Identity::Handlers::CorrectSubjectByForceMajeureHandler.new.call(cmd)
      head :no_content
    rescue ArgumentError, ActionController::ParameterMissing => e
      render_error(e.message)
    end

    private

    def subject_json(record)
      h = {
        subject_id: record.subject_id,
        tax_id: record.tax_id,
        legal_name: record.legal_name,
        trade_name: record.trade_name,
        status: record.status,
        registration_date: record.registration_date&.to_s,
        contact_entries: record.try(:contact_entries).presence || [],
        address_province: record.try(:address_province),
        address_locality: record.try(:address_locality),
        address_line: record.try(:address_line),
        digital_domicile_id: record.try(:digital_domicile_id)
      }
      h.compact
    end
  end
end
