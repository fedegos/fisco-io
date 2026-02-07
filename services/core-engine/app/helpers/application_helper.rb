# frozen_string_literal: true

# Fisco.io - Helpers de aplicación
# Etiquetas en español para la interfaz

module ApplicationHelper
  TIPO_MOVIMIENTO = {
    "liquidation" => "Liquidación",
    "payment" => "Pago",
    "interest" => "Interés",
    "other" => "Otro"
  }.freeze

  ESTADO_SUJETO = {
    "active" => "Activo",
    "inactive" => "Inactivo",
    "suspended" => "Suspendido"
  }.freeze

  def etiqueta_tipo_movimiento(tipo)
    TIPO_MOVIMIENTO[tipo.to_s] || tipo.to_s
  end

  def etiqueta_estado_sujeto(estado)
    ESTADO_SUJETO[estado.to_s] || estado.to_s
  end
end
