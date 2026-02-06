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
end
