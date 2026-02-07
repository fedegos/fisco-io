# frozen_string_literal: true

# Fisco.io - Portal operadores: Padrón de sujetos
# Listado, export JSON, import idempotente por subject_id (UUID)

module Operadores
  class PadronSujetosController < ApplicationController
    before_action :set_sujeto, only: [:edit, :update, :desactivar]

    def index
      @sujetos = SubjectReadModel.order(created_at: :desc)
      @sujetos = @sujetos.where("legal_name ILIKE ? OR tax_id ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    end

    def new
      @sujeto = SubjectReadModel.new
    end

    def create
      cmd = Identity::Commands::RegisterSubject.new(
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
      result = Identity::Handlers::RegisterSubjectHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto creado correctamente."
    rescue StandardError => e
      @sujeto = SubjectReadModel.new(**(params[:subject_read_model]&.permit(:tax_id, :legal_name, :trade_name)&.to_h || {}).symbolize_keys)
      flash.now[:alert] = "Error al crear: #{e.message}"
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      cmd = Identity::Commands::UpdateSubject.new(
        aggregate_id: @sujeto.subject_id,
        legal_name: params[:subject_read_model][:legal_name].to_s.presence,
        trade_name: params[:subject_read_model][:trade_name].to_s.presence
      )
      unless cmd.legal_name.present?
        flash.now[:alert] = "Razón social es obligatoria."
        render :edit, status: :unprocessable_entity
        return
      end
      Identity::Handlers::UpdateSubjectHandler.new.call(cmd)
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto actualizado."
    rescue StandardError => e
      flash.now[:alert] = "Error al actualizar: #{e.message}"
      render :edit, status: :unprocessable_entity
    end

    def desactivar
      Identity::Handlers::DeactivateSubjectHandler.new.call(Identity::Commands::DeactivateSubject.new(aggregate_id: @sujeto.subject_id))
      redirect_to operadores_padron_sujetos_path, notice: "Sujeto desactivado."
    rescue StandardError => e
      redirect_to operadores_padron_sujetos_path, alert: "Error al desactivar: #{e.message}"
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
        cmd = Identity::Commands::RegisterSubject.new(
          aggregate_id: subject_id,
          tax_id: item["tax_id"].to_s.presence || "IMPORT-#{subject_id[0..7]}",
          legal_name: item["legal_name"].to_s.presence || "Sin nombre",
          trade_name: item["trade_name"].to_s.presence
        )
        Identity::Handlers::RegisterSubjectHandler.new.call(cmd)
        created += 1
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
        registration_date: r.registration_date&.to_s
      }
    end
  end
end
