# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_24_110143) do
  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "tax_id"
    t.string "address"
    t.string "zip_code"
    t.string "city"
    t.string "country_code"
    t.string "email"
    t.string "client_code"
    t.string "contact_person"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_details", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "product_code"
    t.string "description"
    t.integer "quantity"
    t.decimal "unit_price", precision: 10, scale: 2
    t.decimal "tax_rate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_details_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
    t.string "from"
    t.string "number"
    t.date "date"
    t.date "due_date"
    t.string "currency", default: "EUR"
    t.string "payment_method"
    t.string "payment_terms"
    t.string "status"
    t.decimal "subtotal", precision: 12, scale: 2
    t.decimal "tax_total", precision: 12, scale: 2
    t.decimal "total", precision: 12, scale: 2
    t.string "format", null: false
    t.string "file"
    t.string "order_reference"
    t.string "legal_reference"
    t.text "notes"
    t.text "terms"
    t.text "from_address"
    t.text "bill_to_address"
    t.string "logo_url"
    t.string "signature_base64"
    t.text "xml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "invoice_details", "invoices"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "users"
end
