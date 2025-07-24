class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :client, optional: true
  has_many :invoice_details, dependent: :destroy
  
  # Validaciones básicas
  validates :number, presence: true, uniqueness: true
  validates :date, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[pending paid cancelled] }, allow_nil: true
  validates :format, inclusion: { in: %w[ubl facturae facturx pdf] }, allow_nil: true
end
