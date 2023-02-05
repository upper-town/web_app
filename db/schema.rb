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

ActiveRecord::Schema[7.1].define(version: 2023_01_20_102025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admin_permissions", force: :cascade do |t|
    t.string "key", null: false
    t.string "description", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_admin_permissions_on_key", unique: true
  end

  create_table "admin_role_permissions", force: :cascade do |t|
    t.bigint "admin_role_id", null: false
    t.bigint "admin_permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_permission_id"], name: "index_admin_role_permissions_on_admin_permission_id"
    t.index ["admin_role_id", "admin_permission_id"], name: "index_admin_role_permissions_on_role_and_permission", unique: true
  end

  create_table "admin_roles", force: :cascade do |t|
    t.string "key", null: false
    t.string "description", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_admin_roles_on_key", unique: true
  end

  create_table "admin_user_roles", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.bigint "admin_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_role_id"], name: "index_admin_user_roles_on_admin_role_id"
    t.index ["admin_user_id", "admin_role_id"], name: "index_admin_user_roles_on_admin_user_id_and_admin_role_id", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_admin_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
  end

  create_table "apps", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "slug", null: false
    t.string "name", null: false
    t.string "kind", null: false
    t.string "site_url", default: "", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_apps_on_kind"
    t.index ["name"], name: "index_apps_on_name", unique: true
    t.index ["slug"], name: "index_apps_on_slug", unique: true
    t.index ["uuid"], name: "index_apps_on_uuid", unique: true
  end

  create_table "server_stats", force: :cascade do |t|
    t.string "period", null: false
    t.date "reference_date", null: false
    t.bigint "app_id", null: false
    t.string "country_code", null: false
    t.bigint "server_id", null: false
    t.bigint "vote_count", default: 0, null: false
    t.datetime "vote_count_consolidated_at"
    t.bigint "ranking_number"
    t.datetime "ranking_number_consolidated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period", "reference_date", "app_id", "country_code", "server_id"], name: "index_server_stats_on_period_reference_app_country_server", unique: true
    t.index ["server_id"], name: "index_server_stats_on_server_id"
  end

  create_table "server_votes", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "reference_id", default: "", null: false
    t.string "remote_ip", default: "", null: false
    t.bigint "user_account_id"
    t.bigint "app_id", null: false
    t.string "country_code", null: false
    t.bigint "server_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id", "country_code"], name: "index_server_votes_on_app_id_and_country_code"
    t.index ["created_at"], name: "index_server_votes_on_created_at"
    t.index ["server_id"], name: "index_server_votes_on_server_id"
    t.index ["user_account_id"], name: "index_server_votes_on_user_account_id"
    t.index ["uuid"], name: "index_server_votes_on_uuid", unique: true
  end

  create_table "servers", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "name", null: false
    t.string "country_code", null: false
    t.string "site_url", default: "", null: false
    t.string "banner_image_url", default: "", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.bigint "app_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_servers_on_app_id"
    t.index ["country_code"], name: "index_servers_on_country_code"
    t.index ["name", "app_id"], name: "index_servers_on_name_and_app_id", unique: true
    t.index ["uuid"], name: "index_servers_on_uuid", unique: true
  end

  create_table "user_accounts", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_accounts_on_user_id", unique: true
    t.index ["uuid"], name: "index_user_accounts_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.uuid "uuid", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "admin_role_permissions", "admin_permissions"
  add_foreign_key "admin_role_permissions", "admin_roles"
  add_foreign_key "admin_user_roles", "admin_roles"
  add_foreign_key "admin_user_roles", "admin_users"
  add_foreign_key "server_stats", "apps"
  add_foreign_key "server_stats", "servers"
  add_foreign_key "server_votes", "apps"
  add_foreign_key "server_votes", "servers"
  add_foreign_key "server_votes", "user_accounts"
  add_foreign_key "servers", "apps"
  add_foreign_key "user_accounts", "users"
end
