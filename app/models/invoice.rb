class Invoice < ApplicationRecord
  belongs_to :user
  has_many :invoice_items, dependent: :destroy

  # Formatos válidos para exportación
  FORMATS = %w[ubl facturae facturx pdf]

  # Validaciones
  validates :client_name, presence: true
  validates :date, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :format, presence: true, inclusion: { in: FORMATS }
end
