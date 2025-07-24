class AddClientNameAndDateToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :client_name, :string
    add_column :invoices, :date, :date
  end
end
