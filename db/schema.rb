# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_24_180813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "position", default: 0
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "institution_id"
    t.geography "gps_coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "street_1"
    t.string "street_2"
    t.string "zip_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "contact_name"
    t.string "contact_cellphone"
    t.string "contact_email"
    t.string "telephone"
    t.string "open_hours"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lookup"
    t.string "gateway"
    t.string "gateway_id"
    t.jsonb "gateway_data", default: {}
    t.string "formatted_address"
    t.integer "company_id"
    t.integer "network_id"
    t.index ["company_id"], name: "index_addresses_on_company_id"
    t.index ["gateway_data"], name: "index_addresses_on_gateway_data", using: :gin
    t.index ["gps_coordinates"], name: "index_addresses_on_gps_coordinates", using: :gist
    t.index ["institution_id"], name: "index_addresses_on_institution_id"
  end

  create_table "audits", force: :cascade do |t|
    t.string "auditable_id"
    t.string "auditable_type"
    t.string "associated_id"
    t.string "associated_type"
    t.uuid "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.integer "ein"
    t.decimal "max_distance_from_base"
    t.integer "usdot"
    t.integer "mc_number_type", default: 0
    t.integer "mc_number"
    t.string "sacs_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "districts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institutions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "legal_name"
    t.string "uid_type"
    t.string "uid"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "district_id"
    t.integer "beneficiaries"
    t.string "offered_services", default: [], array: true
    t.index ["district_id"], name: "index_institutions_on_district_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string "number"
    t.string "state"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "shipper_id"
    t.index ["shipper_id"], name: "index_licenses_on_shipper_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.uuid "trip_id"
    t.string "name"
    t.text "comments"
    t.jsonb "data", default: {}
    t.geography "gps_coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at"
    t.string "marketplace_order_id"
    t.index ["data"], name: "index_milestones_on_data", using: :gin
    t.index ["gps_coordinates"], name: "index_milestones_on_gps_coordinates", using: :gist
    t.index ["marketplace_order_id"], name: "index_milestones_on_marketplace_order_id"
    t.index ["trip_id"], name: "index_milestones_on_trip_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "expiration"
    t.decimal "amount", precision: 12, scale: 4, default: "0.0"
    t.decimal "bonified_amount", precision: 12, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "with_delivery"
    t.boolean "removed", default: false
    t.boolean "manual_order", default: false
    t.decimal "delivery_cost", precision: 12, scale: 2, default: "0.0"
    t.decimal "delivery_distance", precision: 12, scale: 2, default: "0.0"
    t.decimal "total_weight_in_lb", precision: 18, scale: 6
    t.string "warehouse_address_id"
    t.string "delivery_location_id"
    t.string "marketplace_order_id"
    t.boolean "needs_cooling", default: false
    t.integer "network_id"
    t.index ["marketplace_order_id"], name: "index_orders_on_marketplace_order_id", unique: true
    t.index ["network_id"], name: "index_orders_on_network_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.uuid "shipper_id", null: false
    t.string "payment_method", null: false
    t.string "payment_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shipper_id"], name: "index_payment_methods_on_shipper_id", unique: true
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.uuid "user_id", null: false
    t.jsonb "extras", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["extras"], name: "index_profiles_on_extras", using: :gin
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "role"
    t.string "path", null: false
    t.index ["role", "path"], name: "unique_path_per_route", unique: true
  end

  create_table "shippers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "last_name"
    t.string "gender"
    t.date "birth_date"
    t.string "photo"
    t.boolean "active", default: false
    t.boolean "verified", default: false
    t.date "verified_at"
    t.jsonb "national_ids", default: {}
    t.string "gateway"
    t.string "gateway_id"
    t.jsonb "data", default: {}
    t.jsonb "minimum_requirements", default: {}
    t.jsonb "requirements", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "devices", default: {}
    t.boolean "has_accepted_tdu", default: false
    t.uuid "user_id", null: false
    t.string "status", default: "0"
    t.integer "company_id"
    t.jsonb "working_hours", default: {}
    t.string "first_name"
    t.string "provided_services", array: true
    t.integer "network_id"
    t.index ["company_id"], name: "index_shippers_on_company_id"
    t.index ["data"], name: "index_shippers_on_data", using: :gin
    t.index ["devices"], name: "index_shippers_on_devices", using: :gin
    t.index ["minimum_requirements"], name: "index_shippers_on_minimum_requirements", using: :gin
    t.index ["national_ids"], name: "index_shippers_on_national_ids", using: :gin
    t.index ["network_id"], name: "index_shippers_on_network_id"
    t.index ["requirements"], name: "index_shippers_on_requirements", using: :gin
  end

  create_table "trip_orders", force: :cascade do |t|
    t.uuid "trip_id"
    t.uuid "order_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_trip_orders_on_order_id"
    t.index ["trip_id"], name: "index_trip_orders_on_trip_id"
  end

  create_table "trip_payments", force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.string "payment_method", null: false
    t.string "payment_email"
    t.string "confirmation_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "paid_at"
    t.index ["trip_id"], name: "index_trip_payments_on_trip_id", unique: true
  end

  create_table "trip_status_change_audits", force: :cascade do |t|
    t.uuid "trip_id"
    t.string "status"
    t.string "event"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_trip_status_change_audits_on_trip_id"
  end

  create_table "trip_step_photos", force: :cascade do |t|
    t.uuid "trip_id", null: false
    t.uuid "shipper_id", null: false
    t.integer "step_index", null: false
    t.geography "gps_coordinates", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shipper_id"], name: "index_trip_step_photos_on_shipper_id"
    t.index ["trip_id"], name: "index_trip_step_photos_on_trip_id"
  end

  create_table "trips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shipper_id"
    t.string "status", default: "0"
    t.string "comments"
    t.decimal "amount", precision: 12, scale: 4, default: "0.0"
    t.string "gateway"
    t.string "gateway_id"
    t.jsonb "gateway_data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "steps", default: [], null: false
    t.datetime "start_datetime"
    t.bigint "trip_number", default: -> { "nextval('trip_number_seq'::regclass)" }
    t.decimal "distance", precision: 12, scale: 2, default: "0.0"
    t.text "cancelation_reason"
    t.string "timezone_name", null: false
    t.integer "network_id"
    t.index ["gateway_data"], name: "index_trips_on_gateway_data", using: :gin
    t.index ["network_id"], name: "index_trips_on_network_id"
    t.index ["shipper_id"], name: "index_trips_on_shipper_id"
    t.index ["status"], name: "index_trips_on_status"
    t.index ["steps"], name: "index_trips_on_steps", using: :gin
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.integer "token_expire_at"
    t.integer "login_count", default: 0, null: false
    t.integer "failed_login_count", default: 0, null: false
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.boolean "active", default: false
    t.boolean "confirmed", default: false
    t.integer "roles_mask"
    t.jsonb "settings", default: {}, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "institution_id"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["institution_id"], name: "index_users_on_institution_id"
    t.index ["roles_mask"], name: "index_users_on_roles_mask"
    t.index ["settings"], name: "index_users_on_settings", using: :gin
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "shipper_id"
    t.string "model"
    t.string "brand"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_weight"
    t.integer "truck_type"
    t.string "make"
    t.string "color"
    t.string "license_plate"
    t.string "insurance_provider"
    t.boolean "has_liftgate"
    t.boolean "has_forklift"
    t.integer "gross_vehicle_weight_rating"
    t.index ["shipper_id"], name: "index_vehicles_on_shipper_id"
  end

  create_table "verifications", force: :cascade do |t|
    t.string "verificable_type"
    t.uuid "verificable_id"
    t.jsonb "data", default: {}
    t.datetime "verified_at"
    t.uuid "verified_by"
    t.boolean "expire"
    t.datetime "expire_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_verifications_on_data", using: :gin
    t.index ["verificable_type", "verificable_id"], name: "index_verifications_on_verificable_type_and_verificable_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "institutions"
  add_foreign_key "institutions", "districts"
  add_foreign_key "payment_methods", "shippers"
  add_foreign_key "trip_orders", "orders"
  add_foreign_key "trip_orders", "trips"
  add_foreign_key "trip_payments", "trips"
  add_foreign_key "trip_status_change_audits", "trips"
  add_foreign_key "trip_step_photos", "shippers"
  add_foreign_key "trip_step_photos", "trips"
  add_foreign_key "trips", "shippers"
  add_foreign_key "vehicles", "shippers"
end
