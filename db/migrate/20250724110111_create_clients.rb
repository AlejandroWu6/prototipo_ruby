class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :tax_id
      t.string :email
      t.string :address

      t.timestamps
    end
  end
end
