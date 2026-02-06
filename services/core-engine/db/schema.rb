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

ActiveRecord::Schema[8.1].define(version: 6) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "aggregate_id", null: false
    t.string "aggregate_type", limit: 100, null: false
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.string "event_type", limit: 100, null: false
    t.integer "event_version", default: 1, null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "sequence_number", null: false
    t.datetime "updated_at", null: false
    t.index ["aggregate_id", "event_version"], name: "unique_aggregate_version", unique: true
    t.index ["created_at"], name: "idx_events_created_at"
    t.index ["event_type"], name: "idx_events_type"
    t.index ["sequence_number"], name: "idx_events_sequence"
  end

  create_table "fiscal_valuations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "obligation_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 15, scale: 2, null: false
    t.integer "year", null: false
    t.index ["obligation_id", "year"], name: "idx_fiscal_valuations_oblig_year", unique: true
  end

  create_table "inmobiliario_determination_configs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "formula_base_expression", default: "valuacion * 1.0", null: false
    t.integer "installments_per_year", default: 4, null: false
    t.string "tax_type", default: "inmobiliario", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["tax_type", "year"], name: "idx_inmob_config_tax_year", unique: true
  end

  create_table "inmobiliario_rate_brackets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "base_from", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "base_to", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.decimal "minimum_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.decimal "rate_pct", precision: 8, scale: 4, null: false
    t.string "tax_type", default: "inmobiliario", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["tax_type", "year"], name: "idx_inmob_brackets_tax_year"
  end

  create_table "snapshots", primary_key: "aggregate_id", id: :uuid, default: nil, force: :cascade do |t|
    t.string "aggregate_type", limit: 100, null: false
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.datetime "updated_at", null: false
    t.integer "version", null: false
    t.index ["aggregate_type"], name: "idx_snapshots_type"
  end

  create_table "subjects", primary_key: "subject_id", id: :uuid, default: nil, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "legal_name", null: false
    t.date "registration_date", null: false
    t.string "status", default: "active", null: false
    t.string "tax_id", null: false
    t.string "trade_name"
    t.datetime "updated_at", null: false
    t.index ["status"], name: "idx_subjects_status"
    t.index ["tax_id"], name: "idx_subjects_tax_id"
  end

  create_table "tax_account_balances", primary_key: "obligation_id", id: :uuid, default: nil, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "current_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "interest_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.date "last_liquidation_date"
    t.date "last_payment_date"
    t.decimal "principal_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.uuid "subject_id", null: false
    t.string "tax_type", null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 0, null: false
    t.index ["subject_id"], name: "idx_tax_account_balances_subject_id"
    t.index ["tax_type"], name: "idx_tax_account_balances_tax_type"
  end
end
