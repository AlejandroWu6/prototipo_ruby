class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string  :from                       # Emisor

      t.string  :number                     # Código/número de la factura
      t.date    :issue_date                 # Fecha de emisión
      t.date    :due_date                   # Fecha de vencimiento
      t.string  :currency, default: "EUR"   # EUR, USD...
      t.string  :payment_method             # transferencia, tarjeta...
      t.string  :payment_terms              # Ej. "30 días"
      t.string  :status                     # emitida, pagada, cancelada...

      t.decimal :subtotal, precision: 12, scale: 2
      t.decimal :tax_total, precision: 12, scale: 2
      t.decimal :total, precision: 12, scale: 2

      t.string  :format, null: false                    # pdf, facturae, ubl, etc.
      t.string  :file                       # nombre de archivo generado

      t.string  :order_reference            # Pedido o referencia externa
      t.string  :legal_reference            # Contrato o documento legal

      t.text    :notes                      # Notas visibles al cliente
      t.text    :terms                      # Términos y condiciones personalizados
      t.text    :from_address               # Dirección personalizada "From"
      t.text    :bill_to_address            # Dirección personalizada "Bill To"

      t.string  :logo_url                   # Ruta o referencia a logo (si se usa)
      t.string  :signature_base64           # Firma opcional (como base64 o referencia)

      t.text    :xml               # Contenido XML Facturae 3.2

      t.timestamps
    end
  end
end
