class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name                     # Razón social
      t.string :tax_id                  # NIF/CIF/NIE
      t.string :address
      t.string :zip_code
      t.string :city
      t.string :country_code            # ISO 3166-1 Alpha-2 (ES, FR, DE...)
      t.string :email
      t.string :client_code             # Código obligatorio en Facturae
      t.string :contact_person
      t.string :phone

      t.timestamps
    end
  end
end
