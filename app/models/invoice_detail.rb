class InvoiceDetail < ApplicationRecord
  belongs_to :invoice

  def total_line
    quantity * unit_price * (1 - discount.to_f / 100)
  end

end
