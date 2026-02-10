# frozen_string_literal: true

# Fisco.io - Portal operadores: tabla de tramos/alícuotas por año (inmobiliario)

module Operadores
  class InmobiliarioBracketsController < ApplicationController
    before_action :set_year

    def index
      @brackets = InmobiliarioRateBracket.for_tax_year("inmobiliario", @year)
    end

    def new
      @bracket = InmobiliarioRateBracket.new(tax_type: "inmobiliario", year: @year, position: next_position)
    end

    def create
      @bracket = InmobiliarioRateBracket.new(bracket_params.merge(tax_type: "inmobiliario", year: @year))
      if @bracket.save
        redirect_to operadores_inmobiliario_brackets_path(@year), notice: "Tramo creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update_all
      attributes = params.require(:brackets).permit(brackets_attributes: [:id, :base_from, :base_to, :rate_pct, :minimum_amount, :position, :_destroy, :tramo_final])
      next_pos = (InmobiliarioRateBracket.where(tax_type: "inmobiliario", year: @year).maximum(:position) || 0) + 1
      rows = (attributes[:brackets_attributes] || {}).values.map { |r| r.to_h.with_indifferent_access }
      validate_brackets_coverage!(rows)
      InmobiliarioRateBracket.transaction do
        rows.each do |row|
          base_to = row[:tramo_final].to_s == "1" || row[:base_to].blank? ? nil : row[:base_to]
          if row[:_destroy].to_s == "1"
            InmobiliarioRateBracket.where(id: row[:id], tax_type: "inmobiliario", year: @year).destroy_all if row[:id].present?
          elsif row[:id].present?
            bracket = InmobiliarioRateBracket.find_by(id: row[:id], tax_type: "inmobiliario", year: @year)
            next unless bracket
            bracket.assign_attributes(base_from: row[:base_from], base_to: base_to, rate_pct: row[:rate_pct], minimum_amount: row[:minimum_amount], position: row[:position])
            bracket.save!
          else
            next if row[:base_from].blank? && base_to.blank? && row[:rate_pct].blank?
            pos = row[:position].presence || next_pos
            next_pos += 1 if row[:position].blank?
            InmobiliarioRateBracket.create!(
              tax_type: "inmobiliario",
              year: @year,
              base_from: row[:base_from].presence || 0,
              base_to: base_to,
              rate_pct: row[:rate_pct].presence || 0,
              minimum_amount: row[:minimum_amount].presence || 0,
              position: pos
            )
          end
        end
      end
      redirect_to operadores_inmobiliario_brackets_path(@year), notice: "Tramos guardados."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to operadores_inmobiliario_brackets_path(@year), alert: "Error al guardar: #{e.record.errors.full_messages.join(', ')}"
    rescue ArgumentError => e
      redirect_to operadores_inmobiliario_brackets_path(@year), alert: "Error: #{e.message}"
    end

    private

    def set_year
      @year = params[:year].to_i
    end

    def next_position
      (InmobiliarioRateBracket.where(tax_type: "inmobiliario", year: @year).maximum(:position) || 0) + 1
    end

    def bracket_params
      params.require(:inmobiliario_rate_bracket).permit(:base_from, :base_to, :rate_pct, :minimum_amount, :position)
    end

    # Valida que los tramos (sin los marcados para eliminar) cubran de 0 a infinito sin huecos.
    def validate_brackets_coverage!(rows)
      active = rows.reject { |r| r[:_destroy].to_s == "1" }
                   .select { |r| r[:base_from].present? || r[:base_to].present? || r[:rate_pct].present? }
      return if active.empty?
      ordered = active.sort_by { |r| (r[:position].presence || 0).to_i }
      first = ordered.first
      unless first[:base_from].present? && first[:base_from].to_f.zero?
        raise ArgumentError, "El primer tramo debe comenzar en 0 (base desde = 0)."
      end
      ordered.each_cons(2) do |a, b|
        a_to = a[:tramo_final].to_s == "1" || a[:base_to].blank? ? nil : a[:base_to].to_s
        b_from = b[:base_from].to_s
        if a_to.nil?
          raise ArgumentError, "El tramo final (hasta ∞) debe ser el último; no puede haber tramos después."
        end
        unless a_to == b_from
          raise ArgumentError, "Los tramos deben ser consecutivos sin huecos: hasta #{a_to} y desde #{b_from} no coinciden."
        end
      end
      last = ordered.last
      last_to_nil = last[:tramo_final].to_s == "1" || last[:base_to].blank?
      unless last_to_nil
        raise ArgumentError, "El último tramo debe ser 'Tramo final (hasta ∞)' o tener base hasta que cierre el rango."
      end
    end
  end
end
