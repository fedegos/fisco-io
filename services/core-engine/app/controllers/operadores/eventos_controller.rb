# frozen_string_literal: true

# Fisco.io - Portal operadores: stream de eventos (event store)
# Solo lectura; filtros por event_type, aggregate_type, fechas, sequence

module Operadores
  class EventosController < ApplicationController
    def index
      @eventos = scope.order(sequence_number: :desc).limit(100)
      @event_types = EventRecord.distinct.pluck(:event_type).sort
      @aggregate_types = EventRecord.distinct.pluck(:aggregate_type).sort
    end

    private

    def scope
      s = EventRecord.all
      s = s.where(event_type: params[:event_type]) if params[:event_type].present?
      s = s.where(aggregate_type: params[:aggregate_type]) if params[:aggregate_type].present?
      s = s.where("sequence_number >= ?", params[:from_sequence]) if params[:from_sequence].present?
      s = s.where("sequence_number <= ?", params[:to_sequence]) if params[:to_sequence].present?
      s = s.where("created_at >= ?", params[:from_date]) if params[:from_date].present?
      s = s.where("created_at <= ?", parse_end_of_day(params[:to_date])) if params[:to_date].present?
      s
    end

    def parse_end_of_day(value)
      return nil if value.blank?
      Date.parse(value.to_s).end_of_day
    rescue ArgumentError
      nil
    end
  end
end
