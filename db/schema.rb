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

ActiveRecord::Schema[7.1].define(version: 2025_01_01_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "attendance_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_id", null: false
    t.uuid "company_id", null: false
    t.integer "attendance_type", null: false
    t.datetime "timestamp", null: false
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.date "record_date", null: false
    t.boolean "is_late", default: false
    t.integer "minutes_late", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_type"], name: "index_attendance_records_on_attendance_type"
    t.index ["company_id"], name: "index_attendance_records_on_company_id"
    t.index ["employee_id", "record_date"], name: "index_attendance_records_on_employee_id_and_record_date"
    t.index ["employee_id"], name: "index_attendance_records_on_employee_id"
    t.index ["is_late"], name: "index_attendance_records_on_is_late"
    t.index ["record_date"], name: "index_attendance_records_on_record_date"
    t.index ["timestamp"], name: "index_attendance_records_on_timestamp"
  end

  create_table "companies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.time "work_start_time", default: "2000-01-01 08:00:00"
    t.time "work_end_time", default: "2000-01-01 17:00:00"
    t.integer "late_threshold_minutes", default: 15
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name"
  end

  create_table "company_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "company_id", null: false
    t.string "name", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 11, scale: 8, null: false
    t.integer "radius_meters", default: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_locations_on_company_id"
    t.index ["latitude", "longitude"], name: "index_company_locations_on_latitude_and_longitude"
  end

  create_table "employees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "company_id", null: false
    t.string "name", null: false
    t.string "dni", null: false
    t.string "phone"
    t.string "email"
    t.string "job_position"
    t.decimal "salary", precision: 10, scale: 2
    t.string "pin_hash", null: false
    t.string "password_digest", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "dni"], name: "index_employees_on_company_id_and_dni", unique: true
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["is_active"], name: "index_employees_on_is_active"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_id"
    t.uuid "recipient_id", null: false
    t.string "recipient_type", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "message"
    t.jsonb "data"
    t.boolean "is_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["employee_id"], name: "index_notifications_on_employee_id"
    t.index ["is_read"], name: "index_notifications_on_is_read"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient_type_and_recipient_id"
  end

  create_table "payroll_calculations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_id", null: false
    t.uuid "company_id", null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.integer "total_days_worked", default: 0
    t.integer "total_hours_worked", default: 0
    t.integer "overtime_hours", default: 0
    t.integer "late_days", default: 0
    t.integer "total_late_minutes", default: 0
    t.decimal "base_salary", precision: 10, scale: 2
    t.decimal "overtime_pay", precision: 10, scale: 2, default: "0.0"
    t.decimal "bonus", precision: 10, scale: 2, default: "0.0"
    t.decimal "deductions", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_earnings", precision: 10, scale: 2
    t.decimal "net_pay", precision: 10, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_payroll_calculations_on_company_id"
    t.index ["employee_id", "period_start"], name: "index_payroll_calculations_on_employee_id_and_period_start"
    t.index ["employee_id"], name: "index_payroll_calculations_on_employee_id"
    t.index ["period_end"], name: "index_payroll_calculations_on_period_end"
    t.index ["period_start"], name: "index_payroll_calculations_on_period_start"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "company_id", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "email"], name: "index_profiles_on_company_id_and_email", unique: true
    t.index ["company_id"], name: "index_profiles_on_company_id"
    t.index ["email"], name: "index_profiles_on_email", unique: true
  end

  create_table "vacation_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employee_id", null: false
    t.uuid "company_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "reason"
    t.integer "status", default: 0
    t.datetime "reviewed_at"
    t.uuid "reviewed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vacation_requests_on_company_id"
    t.index ["employee_id", "start_date"], name: "index_vacation_requests_on_employee_id_and_start_date"
    t.index ["employee_id"], name: "index_vacation_requests_on_employee_id"
    t.index ["status"], name: "index_vacation_requests_on_status"
  end

  add_foreign_key "attendance_records", "companies"
  add_foreign_key "attendance_records", "employees"
  add_foreign_key "company_locations", "companies"
  add_foreign_key "employees", "companies"
  add_foreign_key "notifications", "employees"
  add_foreign_key "payroll_calculations", "companies"
  add_foreign_key "payroll_calculations", "employees"
  add_foreign_key "profiles", "companies"
  add_foreign_key "vacation_requests", "companies"
  add_foreign_key "vacation_requests", "employees"
end
