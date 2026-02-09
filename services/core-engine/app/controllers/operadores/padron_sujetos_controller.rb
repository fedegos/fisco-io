# frozen_string_literal: true

# Fisco.io - Portal operadores: Padrón de sujetos
# Listado, export JSON, import idempotente por subject_id (UUID)

module Operadores
  class PadronSujetosController < ApplicationController
    before_action :set_sujeto, only: [:show, :edit, :update, :desactivar, :domicilio, :domicilio_update, :corregir_fuerza_mayor, :corregir_fuerza_mayor_update]

    PER_PAGE = 25
    MAX_PER_PAGE = 100

    def index
      scope = SubjectReadModel.order(created_at: :desc)
      scope = scope.where("legal_name ILIKE ? OR tax_id ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @total_count = scope.count
      @per_page = [(params[:per_page].to_i.positive? ? params[:per_page].to_i : PER_PAGE), MAX_PER_PAGE].min
      @page = [params[:page].to_i, 1].max
      @sujetos = scope.offset((@page - 1) * @per_page).limit(@per_page)
    end

    def new
      @sujeto = SubjectReadModel.new
    end

    def create
      cmd = Identity::Commands::EnrollSubject.new(
        tax_id: params[:subject_read_model][:tax_id].to_s.presence,
        legal_name: params[:subject_read_model][:legal_name].to_s.presence,
        trade_name: params[:subject_read_model][:trade_name].to_s.presence
      )
      unless cmd.legal_name.present? && cmd.tax_id.present?
        @sujeto = SubjectReadModel.new(**(params[:subject_read_model]&.permit(:tax_id, :legal_name, :trade_name)&.to_h || {}).symbolize_keys)
        flash.now[:alert] = "Razón social y CUIT/CUIL son obligatorios."
        render :new, status: :unprocessable_entity
        return
      end
      result = Identity::Handlers::EnrollSubjectHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto creado correctamente."
    rescue StandardError => e
      @sujeto = SubjectReadModel.new(**(params[:subject_read_model]&.permit(:tax_id, :legal_name, :trade_name)&.to_h || {}).symbolize_keys)
      flash.now[:alert] = "Error al crear: #{e.message}"
      render :new, status: :unprocessable_entity
    end

    def show
    end

    def edit
    end

    def update
      permitted = params.require(:subject_read_model).permit(:legal_name, :trade_name, contact_entries: [:type, :value])
      raw_entries = permitted[:contact_entries]
      raw_entries = raw_entries.values if raw_entries.is_a?(Hash)
      contact_entries = Array(raw_entries).filter_map do |ce|
        next unless ce.is_a?(ActionController::Parameters) || ce.respond_to?(:to_h)
        h = ce.to_h.symbolize_keys
        { type: h[:type].to_s.strip, value: h[:value].to_s.strip } if h[:type].present? && h[:value].present?
      end
      cmd = Identity::Commands::UpdateSubjectContactData.new(
        aggregate_id: @sujeto.subject_id,
        legal_name: permitted[:legal_name].to_s.presence,
        trade_name: permitted[:trade_name].to_s.presence,
        contact_entries: contact_entries
      )
      unless cmd.legal_name.present?
        flash.now[:alert] = "Razón social es obligatoria."
        render :edit, status: :unprocessable_entity
        return
      end
      Identity::Handlers::UpdateSubjectContactDataHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto actualizado."
    rescue StandardError => e
      flash.now[:alert] = "Error al actualizar: #{e.message}"
      render :edit, status: :unprocessable_entity
    end

    def desactivar
      Identity::Handlers::CeaseSubjectHandler.new.call(Identity::Commands::CeaseSubject.new(aggregate_id: @sujeto.subject_id))
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto cesado."
    rescue StandardError => e
      redirect_to operadores_padron_sujetos_path, alert: "Error al cesar: #{e.message}"
    end

    def domicilio
    end

    def domicilio_update
      cmd = Identity::Commands::ChangeSubjectDomicile.new(
        aggregate_id: @sujeto.subject_id,
        address_province: params[:subject_read_model][:address_province],
        address_locality: params[:subject_read_model][:address_locality],
        address_line: params[:subject_read_model][:address_line],
        digital_domicile_id: params[:subject_read_model][:digital_domicile_id].to_s.presence
      )
      Identity::Handlers::ChangeSubjectDomicileHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Domicilio actualizado."
    rescue StandardError => e
      flash.now[:alert] = "Error al actualizar domicilio: #{e.message}"
      render :domicilio, status: :unprocessable_entity
    end

    def corregir_fuerza_mayor
    end

    def corregir_fuerza_mayor_update
      obs = params[:operator_observations].to_s.strip
      if obs.blank?
        flash.now[:alert] = "Observaciones del operador son obligatorias."
        render :corregir_fuerza_mayor, status: :unprocessable_entity
        return
      end
      attrs = params.permit(:legal_name, :trade_name, :digital_domicile_id, :address_province, :address_locality, :address_line).to_h.slice("legal_name", "trade_name", "digital_domicile_id", "address_province", "address_locality", "address_line").compact_blank
      if attrs.blank?
        flash.now[:alert] = "Indique al menos un campo a corregir."
        render :corregir_fuerza_mayor, status: :unprocessable_entity
        return
      end
      cmd = Identity::Commands::CorrectSubjectByForceMajeure.new(
        aggregate_id: @sujeto.subject_id,
        operator_observations: obs,
        **attrs.symbolize_keys
      )
      Identity::Handlers::CorrectSubjectByForceMajeureHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Corrección por fuerza mayor registrada."
    rescue StandardError => e
      flash.now[:alert] = "Error: #{e.message}"
      render :corregir_fuerza_mayor, status: :unprocessable_entity
    end

    def export
      records = SubjectReadModel.order(created_at: :desc)
      records = records.where("legal_name ILIKE ? OR tax_id ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      json = records.map { |r| subject_export_json(r) }.to_json
      send_data json, filename: "padron_sujetos_#{Time.current.strftime('%Y%m%d_%H%M')}.json", type: "application/json", disposition: "attachment"
    end

    def import
      unless params[:file].present?
        redirect_to operadores_padron_sujetos_path, alert: "Seleccione un archivo JSON."
        return
      end
      data = JSON.parse(params[:file].read)
      data = [data] unless data.is_a?(Array)
      created = 0
      skipped = 0
      errors = []
      data.each_with_index do |item, idx|
        subject_id = item["subject_id"]&.presence
        unless subject_id
          errors << "Fila #{idx + 1}: falta subject_id"
          next
        end
        if SubjectReadModel.exists?(subject_id: subject_id)
          skipped += 1
          next
        end
        cmd = Identity::Commands::EnrollSubject.new(
          aggregate_id: subject_id,
          tax_id: item["tax_id"].to_s.presence || "IMPORT-#{subject_id[0..7]}",
          legal_name: item["legal_name"].to_s.presence || "Sin nombre",
          trade_name: item["trade_name"].to_s.presence
        )
        Identity::Handlers::EnrollSubjectHandler.new.call(cmd)
        created += 1
        if item["contact_entries"].is_a?(Array) && item["contact_entries"].any?
          ce = item["contact_entries"].filter_map do |e|
            t = (e["type"] || e[:type]).to_s.strip
            v = (e["value"] || e[:value]).to_s.strip
            { type: t, value: v } if t.present? && v.present?
          end
          Identity::Handlers::UpdateSubjectContactDataHandler.new.call(
            Identity::Commands::UpdateSubjectContactData.new(aggregate_id: subject_id, legal_name: item["legal_name"].to_s.presence || "Sin nombre", trade_name: item["trade_name"].to_s.presence, contact_entries: ce)
          )
        end
        if item["address_province"].present? || item["address_locality"].present? || item["address_line"].present?
          Identity::Handlers::ChangeSubjectDomicileHandler.new.call(
            Identity::Commands::ChangeSubjectDomicile.new(aggregate_id: subject_id, address_province: item["address_province"], address_locality: item["address_locality"], address_line: item["address_line"])
          )
        end
      rescue StandardError => e
        errors << "Fila #{idx + 1}: #{e.message}"
      end
      notice = "Importación: #{created} creados, #{skipped} ya existían."
      notice += " Errores: #{errors.join('; ')}" if errors.any?
      redirect_to operadores_padron_sujetos_path, notice: notice
    end

    private

    def set_sujeto
      @sujeto = SubjectReadModel.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to operadores_padron_sujetos_path, alert: "Sujeto no encontrado."
    end

    def subject_export_json(r)
      {
        subject_id: r.subject_id,
        tax_id: r.tax_id,
        legal_name: r.legal_name,
        trade_name: r.trade_name,
        status: r.status,
        registration_date: r.registration_date&.to_s,
        contact_entries: r.try(:contact_entries).presence || [],
        address_province: r.try(:address_province),
        address_locality: r.try(:address_locality),
        address_line: r.try(:address_line)
      }.compact
    end
  end
end
