class AddFormatToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :format, :string
  end
end
