# frozen_string_literal: true

# Fisco.io - Account movement read model (cuenta corriente)
# Un movimiento: débito (liquidación, interés) o crédito (pago)

class AccountMovement < ActiveRecord::Base
  self.table_name = "account_movements"

  TYPES = %w[liquidation payment interest other].freeze
  DEBIT_CREDIT = %w[debit credit].freeze

  belongs_to :obligation, class_name: "TaxAccountBalance", foreign_key: "obligation_id", primary_key: "obligation_id", optional: true

  validates :obligation_id, :movement_type, :amount, :debit_credit, :movement_date, presence: true
  validates :movement_type, inclusion: { in: TYPES }
  validates :debit_credit, inclusion: { in: DEBIT_CREDIT }
  validates :amount, numericality: { greater_than: 0 }

  # Etiqueta en español para la UI (texto externo)
  MOVEMENT_TYPE_LABELS = { "liquidation" => "Liquidación", "payment" => "Pago", "interest" => "Interés", "other" => "Otro" }.freeze

  def movement_type_label
    MOVEMENT_TYPE_LABELS[movement_type.to_s] || movement_type.to_s
  end
end
