class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true

      t.string  :number               # Código/número de la factura
      t.date    :date                 # Fecha de emisión
      t.date    :due_date             # Fecha de vencimiento
      t.string  :currency, default: "EUR"
      t.string  :payment_method       # 'transferencia', 'tarjeta', etc.
      t.string  :payment_terms        # '30 días', etc.
      t.string  :status               # 'emitida', 'pagada', etc.

      t.decimal :subtotal, precision: 12, scale: 2
      t.decimal :tax_total, precision: 12, scale: 2
      t.decimal :total, precision: 12, scale: 2

      t.string  :format               # 'pdf', 'ubl', 'facturx', 'facturae'
      t.string  :file                 # nombre del archivo generado

      t.string  :order_reference      # Referencia del pedido (opcional)
      t.string  :legal_reference      # Contrato u otros documentos legales
      t.text    :notes                # Notas visibles


      t.timestamps
    end
  end
end
