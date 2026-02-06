# frozen_string_literal: true

# Fisco.io - JurisdictionConfig specs (TDD)
# Carga YAML de jurisdicción y expone config por tax_type

require "rails_helper"

RSpec.describe JurisdictionConfig do
  describe ".for" do
    it "carga la configuración de la jurisdicción por código" do
      config = described_class.for(:arba)

      expect(config).to be_a(described_class)
      expect(config.jurisdiction_code).to eq("arba")
      expect(config.jurisdiction_name).to eq("Buenos Aires")
    end

    it "devuelve nil si el archivo de jurisdicción no existe" do
      config = described_class.for(:inexistente)

      expect(config).to be_nil
    end
  end

  describe "#tax_type_config" do
    let(:config) { described_class.for(:arba) }

    before { skip "archivo config/jurisdictions/arba.yml requerido" unless config }

    it "devuelve la config del tipo inmobiliario" do
      inmobiliario = config.tax_type_config("inmobiliario")

      expect(inmobiliario).to be_a(Hash)
      expect(inmobiliario["nature"]).to eq("asset_based")
      expect(inmobiliario["determination"]).to eq("pre_determined")
    end

    it "incluye períodos mensuales con payment_due_date para inmobiliario" do
      inmobiliario = config.tax_type_config("inmobiliario")

      expect(inmobiliario["periods"]["monthly"]).to be_present
      expect(inmobiliario["periods"]["monthly"]["payment_due_date"]).to eq("day" => 20, "of" => "next_month")
    end

    it "incluye alícuotas por defecto y por categoría para inmobiliario" do
      inmobiliario = config.tax_type_config("inmobiliario")

      expect(inmobiliario["rates"]["default"]).to eq(0.01)
      expect(inmobiliario["rates"]["for_category"]["residencial"]).to eq(0.008)
      expect(inmobiliario["rates"]["for_category"]["comercial"]).to eq(0.012)
    end

    it "devuelve nil para un tax_type no configurado" do
      expect(config.tax_type_config("impuesto_fantasma")).to be_nil
    end
  end
end
