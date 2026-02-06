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
