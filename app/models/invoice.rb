class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :invoice_details, dependent: :destroy
  
  # Validaciones básicas
  validates :number, presence: true, uniqueness: true
  validates :date, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending paid cancelled] }
  validates :format, inclusion: { in: %w[ubl facturae facturx pdf] }

  # Validaciones adicionales
  accepts_nested_attributes_for :invoice_details, allow_destroy: true

end
