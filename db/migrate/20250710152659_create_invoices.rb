class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      # t.references :client, foreign_key: true  # Comentado hasta que crees la tabla clients

      t.string  :title
      t.string  :number
      t.string  :format
      t.string  :client_name
      t.date    :date
      t.decimal :total, precision: 12, scale: 2
      t.string  :currency
      t.string  :status
      t.text    :notes
      t.date    :due_date
      t.string  :payment_method
      t.string  :legal_reference
      t.string  :file

      t.timestamps
    end
  end
end
