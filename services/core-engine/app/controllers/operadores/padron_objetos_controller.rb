# frozen_string_literal: true

# Fisco.io - Portal operadores: Padrón de objetos (obligaciones)
# Listado, export JSON, import idempotente por obligation_id (UUID)

module Operadores
  class PadronObjetosController < ApplicationController
    before_action :set_obligacion, only: [:show, :edit, :update, :cerrar, :create_valuacion, :update_valuacion]

    def index
      @obligaciones = TaxAccountBalance.order(updated_at: :desc)
      @obligaciones = @obligaciones.where(tax_type: params[:tax_type]) if params[:tax_type].present?
      @obligaciones = @obligaciones.where("external_id ILIKE ? OR obligation_id::text ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    end

    def new
      @obligacion = TaxAccountBalance.new
    end

    def create
      obligation_id = params[:tax_account_balance][:obligation_id].presence || SecureRandom.uuid
      cmd = Obligations::Commands::CreateTaxObligation.new(
        obligation_id: obligation_id,
        primary_subject_id: params[:tax_account_balance][:subject_id].to_s.presence,
        tax_type: params[:tax_account_balance][:tax_type].to_s.presence || "inmobiliario",
        role: params[:tax_account_balance][:role].to_s.presence || "contribuyente",
        external_id: params[:tax_account_balance][:external_id].to_s.presence
      )
      unless cmd.primary_subject_id.present? && cmd.tax_type.present?
        flash.now[:alert] = "Sujeto y tipo de impuesto son obligatorios."
        @obligacion = TaxAccountBalance.new(**(params[:tax_account_balance]&.permit(:subject_id, :tax_type, :role, :external_id)&.to_h || {}).symbolize_keys)
        render :new, status: :unprocessable_entity
        return
      end
      Obligations::Handlers::CreateTaxObligationHandler.new.call(cmd)
      redirect_to operadores_padron_objeto_path(obligation_id), notice: "Obligación creada."
    rescue StandardError => e
      flash.now[:alert] = "Error al crear: #{e.message}"
      @obligacion = TaxAccountBalance.new(**(params[:tax_account_balance]&.permit(:subject_id, :tax_type, :role, :external_id)&.to_h || {}).symbolize_keys)
      render :new, status: :unprocessable_entity
    end

    def show
      @valuaciones = FiscalValuation.where(obligation_id: @obligacion.obligation_id).order(year: :desc)
    end

    def edit
    end

    def update
      cmd = Obligations::Commands::UpdateObligationData.new(
        obligation_id: @obligacion.obligation_id,
        external_id: params[:tax_account_balance][:external_id].to_s.presence
      )
      Obligations::Handlers::UpdateObligationDataHandler.new.call(cmd)
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), notice: "Obligación actualizada."
    rescue StandardError => e
      flash.now[:alert] = "Error al actualizar: #{e.message}"
      render :edit, status: :unprocessable_entity
    end

    def cerrar
      Obligations::Handlers::CloseTaxObligationHandler.new.call(Obligations::Commands::CloseTaxObligation.new(obligation_id: @obligacion.obligation_id))
      redirect_to operadores_padron_objetos_path, notice: "Obligación cerrada."
    rescue StandardError => e
      redirect_to operadores_padron_objetos_path, alert: "Error al cerrar: #{e.message}"
    end

    def create_valuacion
      year = params[:year].to_i
      value = params[:value].to_s.gsub(",", ".").to_f
      if year < 2000 || value.negative?
        redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), alert: "Año o valor inválido."
        return
      end
      FiscalValuation.find_or_initialize_by(obligation_id: @obligacion.obligation_id, year: year).tap do |v|
        v.value = value
        v.save!
      end
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), notice: "Valuación #{year} guardada."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), alert: "Error al guardar valuación: #{e.message}"
    end

    def update_valuacion
      year = params[:year].to_i
      value = params[:value].to_s.gsub(",", ".").to_f
      v = FiscalValuation.find_by!(obligation_id: @obligacion.obligation_id, year: year)
      v.update!(value: value)
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), notice: "Valuación #{year} actualizada."
    rescue ActiveRecord::RecordNotFound
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), alert: "Valuación no encontrada."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to operadores_padron_objeto_path(@obligacion.obligation_id), alert: "Error al actualizar: #{e.message}"
    end

    def export
      records = TaxAccountBalance.order(updated_at: :desc)
      records = records.where(tax_type: params[:tax_type]) if params[:tax_type].present?
      records = records.where("external_id ILIKE ? OR obligation_id::text ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      json = records.map { |r| obligation_export_json(r) }.to_json
      send_data json, filename: "padron_objetos_#{Time.current.strftime('%Y%m%d_%H%M')}.json", type: "application/json", disposition: "attachment"
    end

    def import
      unless params[:file].present?
        redirect_to operadores_padron_objetos_path, alert: "Seleccione un archivo JSON."
        return
      end
      data = JSON.parse(params[:file].read)
      data = [data] unless data.is_a?(Array)
      created = 0
      skipped = 0
      errors = []
      data.each_with_index do |item, idx|
        obligation_id = item["obligation_id"]&.presence
        primary_subject_id = item["primary_subject_id"]&.presence || item["subject_id"]&.presence
        unless obligation_id && primary_subject_id
          errors << "Fila #{idx + 1}: falta obligation_id o primary_subject_id"
          next
        end
        if TaxAccountBalance.exists?(obligation_id: obligation_id)
          skipped += 1
          next
        end
        cmd = Obligations::Commands::CreateTaxObligation.new(
          obligation_id: obligation_id,
          primary_subject_id: primary_subject_id,
          tax_type: item["tax_type"].to_s.presence || "inmobiliario",
          role: item["role"].to_s.presence || "contribuyente",
          external_id: item["external_id"].to_s.presence
        )
        Obligations::Handlers::CreateTaxObligationHandler.new.call(cmd)
        created += 1
      rescue StandardError => e
        errors << "Fila #{idx + 1}: #{e.message}"
      end
      notice = "Importación: #{created} creados, #{skipped} ya existían."
      notice += " Errores: #{errors.join('; ')}" if errors.any?
      redirect_to operadores_padron_objetos_path, notice: notice
    end

    private

    def set_obligacion
      @obligacion = TaxAccountBalance.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to operadores_padron_objetos_path, alert: "Obligación no encontrada."
    end

    def obligation_export_json(r)
      {
        obligation_id: r.obligation_id,
        external_id: r.external_id,
        subject_id: r.subject_id,
        tax_type: r.tax_type,
        current_balance: r.current_balance.to_f,
        principal_balance: r.principal_balance.to_f,
        interest_balance: r.interest_balance.to_f,
        last_liquidation_date: r.last_liquidation_date&.to_s,
        last_payment_date: r.last_payment_date&.to_s
      }
    end
  end
end
