class Invoice < ApplicationRecord
  belongs_to :user
  has_many :invoice_items
end
