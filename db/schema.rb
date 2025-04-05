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

ActiveRecord::Schema[7.1].define(version: 2025_04_05_153355) do
  create_table "product_metrics", force: :cascade do |t|
    t.integer "product_source_id", null: false
    t.float "rating"
    t.integer "reviews_count"
    t.datetime "collected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_source_id", "collected_at"], name: "index_product_metrics_on_product_source_id_and_collected_at"
    t.index ["product_source_id"], name: "index_product_metrics_on_product_source_id"
  end

  create_table "product_sources", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "url", null: false
    t.string "provider_type", null: false
    t.string "name"
    t.string "status", default: "active"
    t.datetime "last_parsed_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_product_sources_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "telegram_user_id"
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["telegram_user_id"], name: "index_users_on_telegram_user_id", unique: true
  end

  add_foreign_key "product_metrics", "product_sources"
  add_foreign_key "product_sources", "users"
end
