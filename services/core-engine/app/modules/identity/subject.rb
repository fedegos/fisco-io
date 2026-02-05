# frozen_string_literal: true

# Fisco.io - Identity Module
# Sujeto obligado (persona física o jurídica) / Tax subject (natural or legal person)

module Identity
  # Aggregate Root: Subject
  # Solo datos de identidad, segmentación y representación; NO contiene obligations
  # Identity, segmentation and representation only; does not hold obligations
  class Subject < BaseAggregate
    attr_accessor :subject_id, :tax_id, :legal_name, :trade_name,
                  :legal_segments, :administrative_segments, :representatives,
                  :digital_domicile_id, :status, :registration_date

    def initialize(id: nil, version: 0, **attrs)
      super(id: id, version: version)
      @subject_id = attrs[:subject_id]
      @tax_id = attrs[:tax_id]
      @legal_name = attrs[:legal_name]
      @trade_name = attrs[:trade_name]
      @legal_segments = attrs[:legal_segments] || []
      @administrative_segments = attrs[:administrative_segments] || []
      @representatives = attrs[:representatives] || []
      @digital_domicile_id = attrs[:digital_domicile_id]
      @status = attrs[:status]
      @registration_date = attrs[:registration_date]
    end

    # apply_* methods (scaffolding; sin lógica de negocio)
    def apply_SubjectRegistered(event)
      data = event.data
      @subject_id = data["subject_id"]
      @tax_id = data["tax_id"]
      @legal_name = data["legal_name"]
      @trade_name = data["trade_name"]
      @status = data["status"]
      @registration_date = data["registration_date"]
    end

    def apply_SubjectSegmentChanged(event)
      @legal_segments = event.data["legal_segments"] if event.data.key?("legal_segments")
      @administrative_segments = event.data["administrative_segments"] if event.data.key?("administrative_segments")
    end
  end
end
