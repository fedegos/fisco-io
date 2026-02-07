# frozen_string_literal: true

# Fisco.io - Servicio de seeds para demo
# Recibe los casos desde db/seeds.rb y los persiste vía event store y proyecciones.
# Ejemplo: impuesto inmobiliario.

class SeedDemoDataService
  def self.call(sujetos: nil, obligaciones: nil, liquidaciones: nil, pagos: nil)
    return if TaxAccountBalance.any?

    sujetos   ||= default_sujetos
    obligaciones ||= default_obligaciones
    liquidaciones ||= default_liquidaciones
    pagos     ||= default_pagos

    repo = EventStore::Repository.new
    bus = EventStore::EventBus.new
    register_subject = Identity::Handlers::RegisterSubjectHandler.new(repository: repo, event_bus: bus)
    create_obligation = Obligations::Handlers::CreateTaxObligationHandler.new(repository: repo, event_bus: bus)
    create_liquidation = Obligations::Handlers::CreateLiquidationHandler.new(repository: repo, event_bus: bus)
    register_payment = Obligations::Handlers::RegisterPaymentHandler.new(repository: repo, event_bus: bus)

    subject_ids = sujetos.map do |s|
      register_subject.call(
        Identity::Commands::RegisterSubject.new(
          tax_id: s[:tax_id],
          legal_name: s[:legal_name],
          trade_name: s[:trade_name]
        )
      )[:subject_id]
    end

    obligation_ids = obligaciones.map do |o|
      idx = o[:primary_subject_index]
      create_obligation.call(
        Obligations::Commands::CreateTaxObligation.new(
          obligation_id: SecureRandom.uuid,
          primary_subject_id: subject_ids[idx],
          tax_type: o[:tax_type],
          role: o[:role] || "contribuyente",
          external_id: o[:external_id].to_s.presence
        )
      )[:obligation_id]
    end

    liquidaciones.each do |liq|
      obligation_id = obligation_ids[liq[:obligation_index]]
      create_liquidation.call(
        Obligations::Commands::CreateLiquidation.new(
          aggregate_id: obligation_id,
          obligation_id: obligation_id,
          period: liq[:period],
          amount: liq[:amount]
        )
      )
    end

    pagos.each do |p|
      obligation_id = obligation_ids[p[:obligation_index]]
      register_payment.call(
        Obligations::Commands::RegisterPayment.new(
          aggregate_id: obligation_id,
          obligation_id: obligation_id,
          amount: p[:amount]
        )
      )
    end

    true
  end

  def self.default_sujetos
    [
      { tax_id: "20-12345678-9", legal_name: "Demo Comercial SA", trade_name: "Demo SA" },
      { tax_id: "27-98765432-1", legal_name: "Juan Pérez", trade_name: nil }
    ]
  end

  def self.default_obligaciones
    [
      { primary_subject_index: 0, tax_type: "inmobiliario", role: "contribuyente", external_id: "12-10001" },
      { primary_subject_index: 0, tax_type: "inmobiliario", role: "contribuyente", external_id: "12-10002" },
      { primary_subject_index: 1, tax_type: "inmobiliario", role: "contribuyente", external_id: "12-20001" }
    ]
  end

  def self.default_liquidaciones
    [
      { obligation_index: 0, period: "2024-01", amount: 15_000.50 },
      { obligation_index: 0, period: "2024-02", amount: 18_200.00 },
      { obligation_index: 1, period: "2024-01", amount: 42_500.00 },
      { obligation_index: 2, period: "2024-01", amount: 8_750.00 }
    ]
  end

  def self.default_pagos
    [{ obligation_index: 0, amount: 10_000.00 }]
  end
end
