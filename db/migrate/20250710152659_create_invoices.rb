class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :number
      t.decimal :total
      t.string :file

      t.timestamps
    end
  end
end
