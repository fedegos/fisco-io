# frozen_string_literal: true

# Fisco.io - Precálculo por obligación y año (borrador antes de pasar a producción)
# payload: array of { period: "YYYY-MM", amount: decimal }

class DeterminationPreview < ActiveRecord::Base
  self.table_name = "determination_previews"

  validates :year, :obligation_id, :status, presence: true
  validates :year, numericality: { only_integer: true, greater_than: 2000 }
  validates :status, inclusion: { in: %w[draft validated committed] }
  validates :obligation_id, uniqueness: { scope: :year }

  scope :for_year, ->(y) { where(year: y).order(:obligation_id) }
  scope :draft_or_validated, -> { where(status: %w[draft validated]) }

  def annual_total
    return 0 if payload.blank?
    Array(payload).sum { |h| (h["amount"] || h[:amount] || 0).to_d }
  end

  def installments_count
    return 0 if payload.blank?
    Array(payload).size
  end
end
