# frozen_string_literal: true

# Fisco.io - Carga configuración de jurisdicción desde YAML
# Expone tax_type_config(tax_type) para períodos, alícuotas, etc.

class JurisdictionConfig
  attr_reader :jurisdiction_code, :jurisdiction_name, :data

  def self.for(code)
    path = Rails.root.join("config", "jurisdictions", "#{code}.yml")
    return nil unless File.file?(path)

    data = YAML.load_file(path)
    new(
      jurisdiction_code: data.dig("jurisdiction", "code") || code.to_s,
      jurisdiction_name: data.dig("jurisdiction", "name"),
      data: data
    )
  end

  def initialize(jurisdiction_code:, jurisdiction_name:, data:)
    @jurisdiction_code = jurisdiction_code
    @jurisdiction_name = jurisdiction_name
    @data = data
  end

  def tax_type_config(tax_type)
    data.dig("tax_types", tax_type.to_s)
  end

  # Configuración del identificador externo mostrable por tipo de impuesto
  # external_id: { label:, regex:, description: }
  def external_id_config(tax_type)
    tax_type_config(tax_type)&.dig("external_id")
  end

  # Valida external_id contra el regex del tax_type (si está configurado).
  # jurisdiction_code: ej. "arba". Devuelve [ok, error_message].
  def self.validate_external_id(tax_type:, external_id:, jurisdiction_code: "arba")
    return [true, nil] if external_id.blank?
    config = JurisdictionConfig.for(jurisdiction_code)
    cfg = config&.external_id_config(tax_type)
    return [true, nil] unless cfg && cfg["regex"].present?
    regex = Regexp.new(cfg["regex"])
    if regex.match?(external_id.to_s.strip)
      [true, nil]
    else
      label = cfg["label"] || "Identificador"
      [false, "#{label} no cumple el formato esperado"]
    end
  end
end
