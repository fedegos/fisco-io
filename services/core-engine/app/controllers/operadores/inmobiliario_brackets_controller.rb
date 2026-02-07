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
      attributes = params.require(:brackets).permit(brackets_attributes: [:id, :base_from, :base_to, :rate_pct, :minimum_amount, :position, :_destroy])
      next_pos = (InmobiliarioRateBracket.where(tax_type: "inmobiliario", year: @year).maximum(:position) || 0) + 1
      InmobiliarioRateBracket.transaction do
        (attributes[:brackets_attributes] || {}).each_value do |row|
          row = row.to_h.with_indifferent_access
          if row[:_destroy].to_s == "1"
            InmobiliarioRateBracket.where(id: row[:id], tax_type: "inmobiliario", year: @year).destroy_all if row[:id].present?
          elsif row[:id].present?
            bracket = InmobiliarioRateBracket.find_by(id: row[:id], tax_type: "inmobiliario", year: @year)
            next unless bracket
            bracket.assign_attributes(base_from: row[:base_from], base_to: row[:base_to], rate_pct: row[:rate_pct], minimum_amount: row[:minimum_amount], position: row[:position])
            bracket.save!
          else
            next if row[:base_from].blank? && row[:base_to].blank? && row[:rate_pct].blank?
            pos = row[:position].presence || next_pos
            next_pos += 1 if row[:position].blank?
            InmobiliarioRateBracket.create!(
              tax_type: "inmobiliario",
              year: @year,
              base_from: row[:base_from].presence || 0,
              base_to: row[:base_to].presence || 0,
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
  end
end
