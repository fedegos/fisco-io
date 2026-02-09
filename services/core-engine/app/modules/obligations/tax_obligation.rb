# frozen_string_literal: true

# Fisco.io - TaxObligation aggregate
# Obligación tributaria (aggregate root): pagos, liquidaciones, intereses, prescripción, cotitularidad
# Tax obligation (aggregate root): payments, liquidations, interest, prescription, co-ownership

module Obligations
  class TaxObligation < BaseAggregate
    attr_accessor :obligation_id, :primary_subject_id, :co_subjects, :tax_type, :role,
                  :asset_id, :object_code, :event_reference, :regime_code,
                  :tax_nature, :determination_method, :account,
                  :configuration_version, :status, :opened_at, :closed_at

    def initialize(id: nil, version: 0, **attrs)
      super(id: id, version: version)
      @obligation_id = attrs[:obligation_id]
      @primary_subject_id = attrs[:primary_subject_id]
      @co_subjects = attrs[:co_subjects] || []
      @tax_type = attrs[:tax_type]
      @role = attrs[:role]
      @asset_id = attrs[:asset_id]
      @object_code = attrs[:object_code]
      @event_reference = attrs[:event_reference]
      @regime_code = attrs[:regime_code]
      @tax_nature = attrs[:tax_nature]
      @determination_method = attrs[:determination_method]
      @account = attrs[:account] || TaxAccount.new(obligation_id: attrs[:obligation_id])
      @configuration_version = attrs[:configuration_version]
      @status = attrs[:status]
      @opened_at = attrs[:opened_at]
      @closed_at = attrs[:closed_at]
    end

    # apply_* (scaffolding; sin lógica de negocio)
    def apply_TaxObligationCreated(event)
      apply_obligation_opened_data(event.data)
    end

    def apply_ObligationOpened(event)
      apply_obligation_opened_data(event.data)
    end

    def apply_TaxObligationUpdated(event)
      d = event.data
      # Only external_id is projected; aggregate could hold more if needed
    end

    def apply_TaxObligationClosed(event)
      apply_obligation_closed_data(event.data)
    end

    def apply_ObligationClosed(event)
      apply_obligation_closed_data(event.data)
    end

    def apply_RevaluationRegistered(_event)
      # No state change on aggregate; projection updates FiscalValuation
    end

    def apply_ObligationCorrectedByForceMajeure(event)
      d = event.data
      # Only external_id is projected; aggregate could hold more if needed
    end

    def apply_TaxLiquidationCreated(_event)
      # TODO: actualizar account
    end

    def apply_PaymentReceived(_event)
      # TODO: actualizar account
    end

    def apply_PaymentAppliedToDebt(_event)
      # TODO: actualizar account
    end

    def apply_InterestAccrued(_event)
      # TODO: actualizar account
    end

    def apply_CoOwnerAdded(event)
      @co_subjects ||= []
      @co_subjects << event.data
    end

    private

    def apply_obligation_opened_data(d)
      @obligation_id = d["obligation_id"]
      @primary_subject_id = d["primary_subject_id"]
      @tax_type = d["tax_type"]
      @role = d["role"]
      @status = d["status"]
      @opened_at = d["opened_at"]
      @account = TaxAccount.new(obligation_id: d["obligation_id"])
    end

    def apply_obligation_closed_data(d)
      @status = "closed"
      @closed_at = d["closed_at"]
    end
  end
end
