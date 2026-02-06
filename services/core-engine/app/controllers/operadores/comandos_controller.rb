# frozen_string_literal: true

# Fisco.io - Portal operadores: catálogo de comandos del dominio
# Listado de comandos disponibles (agregado, parámetros) para documentación

module Operadores
  class ComandosController < ApplicationController
    def index
      @comandos = [
        { name: "RegisterSubject", aggregate: "Identity::Subject", params: %w[tax_id legal_name trade_name] },
        { name: "AuthorizeRepresentative", aggregate: "Identity::Subject", params: %w[subject_id representative_id role] },
        { name: "ChangeSegment", aggregate: "Identity::Subject", params: %w[subject_id segment_code] },
        { name: "CreateTaxObligation", aggregate: "Obligations::TaxObligation", params: %w[obligation_id primary_subject_id tax_type role] },
        { name: "CreateLiquidation", aggregate: "Obligations::TaxObligation", params: %w[aggregate_id obligation_id period amount] },
        { name: "RegisterPayment", aggregate: "Obligations::TaxObligation", params: %w[aggregate_id obligation_id amount allocations] },
        { name: "AccrueInterest", aggregate: "Obligations::TaxObligation", params: %w[obligation_id from_date to_date rate] },
        { name: "AddCoOwner", aggregate: "Obligations::TaxObligation", params: %w[obligation_id subject_id role] }
      ]
    end
  end
end
