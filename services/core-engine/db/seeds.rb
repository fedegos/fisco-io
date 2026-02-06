# frozen_string_literal: true

# Fisco.io - Seeds para demo (impuesto inmobiliario)
# Ejecutar: make seed o bin/rails db:seed
# Replant: make seed-replant

# --- Casos de ejemplo (visibles en este archivo) ---

CASOS_SUJETOS = [
  { tax_id: "20-12345678-9", legal_name: "Demo Comercial SA", trade_name: "Demo SA" },
  { tax_id: "27-98765432-1", legal_name: "Juan Pérez", trade_name: nil }
].freeze

# Cada obligación: :primary_subject_index (índice en CASOS_SUJETOS), :tax_type, opcional :role
CASOS_OBLIGACIONES = [
  { primary_subject_index: 0, tax_type: "inmobiliario", role: "contribuyente" },
  { primary_subject_index: 0, tax_type: "inmobiliario", role: "contribuyente" },
  { primary_subject_index: 1, tax_type: "inmobiliario", role: "contribuyente" }
].freeze

# Cada liquidación: :obligation_index, :period, :amount
CASOS_LIQUIDACIONES = [
  { obligation_index: 0, period: "2024-01", amount: 15_000.50 },
  { obligation_index: 0, period: "2024-02", amount: 18_200.00 },
  { obligation_index: 1, period: "2024-01", amount: 42_500.00 },
  { obligation_index: 2, period: "2024-01", amount: 8_750.00 }
].freeze

# Pagos: :obligation_index, :amount
CASOS_PAGOS = [
  { obligation_index: 0, amount: 10_000.00 }
].freeze

# --- Ejecución ---

puts "Seeds: creando sujetos y obligaciones de demo (impuesto inmobiliario)..."

if TaxAccountBalance.any?
  puts "Ya existen datos (tax_account_balances). Saltando seeds. Usar make seed-replant para reemplazar."
else
  SeedDemoDataService.call(
    sujetos: CASOS_SUJETOS,
    obligaciones: CASOS_OBLIGACIONES,
    liquidaciones: CASOS_LIQUIDACIONES,
    pagos: CASOS_PAGOS
  )
  puts "Seeds listos: #{CASOS_SUJETOS.size} sujetos, #{CASOS_OBLIGACIONES.size} obligaciones, #{CASOS_LIQUIDACIONES.size} liquidaciones, #{CASOS_PAGOS.size} pago(s)."
end
