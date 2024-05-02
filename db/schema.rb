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

ActiveRecord::Schema[7.1].define(version: 2024_05_02_195758) do
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

  create_table "admin_user_account_roles", force: :cascade do |t|
    t.bigint "admin_user_account_id", null: false
    t.bigint "admin_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_role_id"], name: "index_admin_user_account_roles_on_admin_role_id"
    t.index ["admin_user_account_id", "admin_role_id"], name: "index_admin_user_account_roles_account_id_role_id", unique: true
  end

  create_table "admin_user_accounts", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_user_accounts_on_admin_user_id", unique: true
  end

  create_table "admin_user_active_sessions", force: :cascade do |t|
    t.string "token", null: false
    t.string "remote_ip", null: false
    t.string "user_agent", default: "", null: false
    t.datetime "expires_at", null: false
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_user_active_sessions_on_admin_user_id"
    t.index ["token"], name: "index_admin_user_active_sessions_on_token", unique: true
  end

  create_table "admin_user_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_user_tokens_on_admin_user_id"
    t.index ["expires_at"], name: "index_admin_user_tokens_on_expires_at"
    t.index ["purpose"], name: "index_admin_user_tokens_on_purpose"
    t.index ["token"], name: "index_admin_user_tokens_on_token", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "email_confirmed_at"
    t.datetime "email_confirmation_sent_at"
    t.string "password_digest"
    t.datetime "password_reset_at"
    t.datetime "password_reset_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "change_email"
    t.datetime "change_email_confirmed_at"
    t.datetime "change_email_confirmation_sent_at"
    t.datetime "change_email_reverted_at"
    t.datetime "change_email_reversion_sent_at"
    t.datetime "locked_at"
    t.string "locked_reason"
    t.text "locked_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "apps", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.string "site_url", default: "", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name", unique: true
    t.index ["slug"], name: "index_apps_on_slug", unique: true
    t.index ["type"], name: "index_apps_on_type"
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "comment", default: "", null: false
    t.datetime "expected_expiration_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_feature_flags_on_name", unique: true
  end

  create_table "server_banner_images", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "content_type", null: false
    t.binary "blob", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_banner_images_on_server_id"
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

  create_table "server_user_accounts", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.bigint "user_account_id", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_user_accounts_on_server_id"
    t.index ["user_account_id", "server_id"], name: "index_server_user_accounts_on_user_account_id_and_server_id", unique: true
  end

  create_table "server_votes", force: :cascade do |t|
    t.string "reference", default: "", null: false
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
  end

  create_table "server_webhook_configs", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "event_type", null: false
    t.string "url", default: "", null: false
    t.string "notice", default: "", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id", "event_type"], name: "index_server_webhook_configs_on_server_id_and_event_type", unique: true
  end

  create_table "server_webhook_events", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "type", null: false
    t.jsonb "payload", default: {}, null: false
    t.string "status", null: false
    t.string "notice", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_published_at"
    t.datetime "delivered_at"
    t.bigint "server_webhook_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_webhook_events_on_server_id"
    t.index ["server_webhook_config_id"], name: "index_server_webhook_events_on_server_webhook_config_id"
    t.index ["type"], name: "index_server_webhook_events_on_type"
    t.index ["updated_at"], name: "index_server_webhook_events_on_updated_at"
  end

  create_table "server_webhook_secrets", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "secret", null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_webhook_secrets_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "name", null: false
    t.string "country_code", null: false
    t.string "site_url", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.bigint "app_id", null: false
    t.datetime "verified_at"
    t.text "verified_notice", default: "", null: false
    t.datetime "archived_at"
    t.datetime "marked_for_deletion_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_servers_on_app_id"
    t.index ["archived_at"], name: "index_servers_on_archived_at"
    t.index ["country_code"], name: "index_servers_on_country_code"
    t.index ["marked_for_deletion_at"], name: "index_servers_on_marked_for_deletion_at"
    t.index ["name"], name: "index_servers_on_name"
    t.index ["verified_at"], name: "index_servers_on_verified_at"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_accounts_on_user_id", unique: true
  end

  create_table "user_active_sessions", force: :cascade do |t|
    t.string "token", null: false
    t.string "remote_ip", null: false
    t.string "user_agent", default: "", null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_user_active_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_user_active_sessions_on_user_id"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_user_tokens_on_expires_at"
    t.index ["purpose"], name: "index_user_tokens_on_purpose"
    t.index ["token"], name: "index_user_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "email_confirmed_at"
    t.datetime "email_confirmation_sent_at"
    t.string "password_digest"
    t.datetime "password_reset_at"
    t.datetime "password_reset_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "change_email"
    t.datetime "change_email_confirmed_at"
    t.datetime "change_email_confirmation_sent_at"
    t.datetime "change_email_reverted_at"
    t.datetime "change_email_reversion_sent_at"
    t.datetime "locked_at"
    t.string "locked_reason"
    t.text "locked_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_role_permissions", "admin_permissions"
  add_foreign_key "admin_role_permissions", "admin_roles"
  add_foreign_key "admin_user_account_roles", "admin_roles"
  add_foreign_key "admin_user_account_roles", "admin_user_accounts"
  add_foreign_key "admin_user_accounts", "admin_users"
  add_foreign_key "admin_user_active_sessions", "admin_users"
  add_foreign_key "admin_user_tokens", "admin_users"
  add_foreign_key "server_banner_images", "servers"
  add_foreign_key "server_stats", "apps"
  add_foreign_key "server_stats", "servers"
  add_foreign_key "server_user_accounts", "servers"
  add_foreign_key "server_user_accounts", "user_accounts"
  add_foreign_key "server_votes", "apps"
  add_foreign_key "server_votes", "servers"
  add_foreign_key "server_votes", "user_accounts"
  add_foreign_key "server_webhook_configs", "servers"
  add_foreign_key "server_webhook_events", "server_webhook_configs"
  add_foreign_key "server_webhook_events", "servers"
  add_foreign_key "server_webhook_secrets", "servers"
  add_foreign_key "servers", "apps"
  add_foreign_key "user_accounts", "users"
  add_foreign_key "user_active_sessions", "users"
  add_foreign_key "user_tokens", "users"
end
