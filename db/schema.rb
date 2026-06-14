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

ActiveRecord::Schema[8.1].define(version: 2026_06_14_033704) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "countries", force: :cascade do |t|
    t.boolean "available"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "locale"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "inspection_items", force: :cascade do |t|
    t.bigint "checklist_item_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "inspection_id", null: false
    t.integer "repair_priority"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["checklist_item_id"], name: "index_inspection_items_on_checklist_item_id"
    t.index ["inspection_id", "checklist_item_id"], name: "idx_inspection_items_on_inspection_and_item", unique: true
    t.index ["inspection_id"], name: "index_inspection_items_on_inspection_id"
  end

  create_table "inspection_photos", force: :cascade do |t|
    t.string "caption"
    t.bigint "checklist_item_id", null: false
    t.datetime "created_at", null: false
    t.bigint "inspection_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["checklist_item_id"], name: "index_inspection_photos_on_checklist_item_id"
    t.index ["inspection_id", "position"], name: "idx_inspection_photos_on_inspection_and_position", unique: true
    t.index ["inspection_id"], name: "index_inspection_photos_on_inspection_id"
  end

  create_table "inspection_template_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "inspection_template_id", null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["inspection_template_id", "name"], name: "idx_categories_on_template_and_name", unique: true
    t.index ["inspection_template_id"], name: "index_inspection_template_categories_on_inspection_template_id"
  end

  create_table "inspection_template_items", force: :cascade do |t|
    t.boolean "allows_photo", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "inspection_template_category_id", null: false
    t.bigint "inspection_template_id", null: false
    t.string "name"
    t.integer "position"
    t.integer "severity"
    t.datetime "updated_at", null: false
    t.index ["inspection_template_category_id", "position"], name: "idx_items_on_category_and_position", unique: true
    t.index ["inspection_template_category_id"], name: "idx_on_inspection_template_category_id_d9aada3866"
    t.index ["inspection_template_id"], name: "index_inspection_template_items_on_inspection_template_id"
  end

  create_table "inspection_templates", force: :cascade do |t|
    t.string "category"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.boolean "published", default: false, null: false
    t.integer "template_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["country_id"], name: "index_inspection_templates_on_country_id"
    t.index ["name"], name: "index_inspection_templates_on_name"
    t.index ["user_id"], name: "index_inspection_templates_on_user_id"
  end

  create_table "inspections", force: :cascade do |t|
    t.string "client_email"
    t.string "client_name"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "inspection_template_id", null: false
    t.string "pdf_url"
    t.text "property_address"
    t.integer "property_size"
    t.text "signature_data"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.jsonb "utilities_status"
    t.string "weather_conditions"
    t.integer "year_built"
    t.index ["inspection_template_id"], name: "index_inspections_on_inspection_template_id"
    t.index ["status"], name: "index_inspections_on_status"
    t.index ["user_id"], name: "index_inspections_on_user_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.integer "application_fee_amount"
    t.datetime "created_at", null: false
    t.string "currency"
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.jsonb "metadata"
    t.jsonb "object"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.bigint "subscription_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
    t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
  end

  create_table "pay_customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.datetime "deleted_at", precision: nil
    t.jsonb "object"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor", null: false
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "pay_customer_owner_index", unique: true
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor", null: false
    t.string "processor_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.boolean "default"
    t.string "payment_method_type"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "current_period_end", precision: nil
    t.datetime "current_period_start", precision: nil
    t.bigint "customer_id", null: false
    t.jsonb "data"
    t.datetime "ends_at", precision: nil
    t.jsonb "metadata"
    t.boolean "metered"
    t.string "name", null: false
    t.jsonb "object"
    t.string "pause_behavior"
    t.datetime "pause_resumes_at", precision: nil
    t.datetime "pause_starts_at", precision: nil
    t.string "payment_method_id"
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", null: false
    t.string "stripe_account"
    t.datetime "trial_ends_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "event"
    t.string "event_type"
    t.string "processor"
    t.datetime "updated_at", null: false
  end

  create_table "report_templates", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.text "footer_text"
    t.text "header_text"
    t.text "legal_disclaimer"
    t.string "locale", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id", "locale"], name: "index_report_templates_on_country_id_and_locale", unique: true
    t.index ["country_id"], name: "index_report_templates_on_country_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "certification_number"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "license_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "stripe_customer_id"
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "inspection_items", "inspection_template_items", column: "checklist_item_id"
  add_foreign_key "inspection_items", "inspections"
  add_foreign_key "inspection_photos", "inspection_template_items", column: "checklist_item_id"
  add_foreign_key "inspection_photos", "inspections"
  add_foreign_key "inspection_template_categories", "inspection_templates"
  add_foreign_key "inspection_template_items", "inspection_template_categories"
  add_foreign_key "inspection_template_items", "inspection_templates"
  add_foreign_key "inspection_templates", "countries"
  add_foreign_key "inspection_templates", "users"
  add_foreign_key "inspections", "inspection_templates"
  add_foreign_key "inspections", "users"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "report_templates", "countries"
  add_foreign_key "users", "countries"
end
