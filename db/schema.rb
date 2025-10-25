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

ActiveRecord::Schema[8.0].define(version: 2025_09_08_151610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id", unique: true
    t.index ["uuid"], name: "index_accounts_on_uuid", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_account_roles", force: :cascade do |t|
    t.bigint "admin_account_id", null: false
    t.bigint "admin_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_account_id", "admin_role_id"], name: "idx_on_admin_account_id_admin_role_id_29d5733394", unique: true
    t.index ["admin_role_id"], name: "index_admin_account_roles_on_admin_role_id"
  end

  create_table "admin_accounts", force: :cascade do |t|
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_accounts_on_admin_user_id", unique: true
  end

  create_table "admin_codes", force: :cascade do |t|
    t.string "code_digest", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_codes_on_admin_user_id"
    t.index ["code_digest"], name: "index_admin_codes_on_code_digest", unique: true
    t.index ["expires_at"], name: "index_admin_codes_on_expires_at"
    t.index ["purpose"], name: "index_admin_codes_on_purpose"
  end

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

  create_table "admin_sessions", force: :cascade do |t|
    t.string "token_digest", null: false
    t.string "token_last_four", null: false
    t.string "remote_ip", null: false
    t.string "user_agent", default: "", null: false
    t.datetime "expires_at", null: false
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_sessions_on_admin_user_id"
    t.index ["token_digest"], name: "index_admin_sessions_on_token_digest", unique: true
  end

  create_table "admin_tokens", force: :cascade do |t|
    t.string "token_digest", null: false
    t.string "token_last_four", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_admin_tokens_on_admin_user_id"
    t.index ["expires_at"], name: "index_admin_tokens_on_expires_at"
    t.index ["purpose"], name: "index_admin_tokens_on_purpose"
    t.index ["token_digest"], name: "index_admin_tokens_on_token_digest", unique: true
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
    t.datetime "locked_at"
    t.string "locked_reason"
    t.text "locked_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "codes", force: :cascade do |t|
    t.string "code_digest", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_digest"], name: "index_codes_on_code_digest", unique: true
    t.index ["expires_at"], name: "index_codes_on_expires_at"
    t.index ["purpose"], name: "index_codes_on_purpose"
    t.index ["user_id"], name: "index_codes_on_user_id"
  end

  create_table "dummies", force: :cascade do |t|
    t.uuid "uuid"
    t.string "string"
    t.integer "integer"
    t.decimal "decimal"
    t.float "float"
    t.date "date"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string "name", null: false
    t.string "value", null: false
    t.string "comment", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_feature_flags_on_name", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "site_url", default: "", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_games_on_name", unique: true
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "server_accounts", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.bigint "account_id", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "server_id"], name: "index_server_accounts_on_account_id_and_server_id", unique: true
    t.index ["server_id"], name: "index_server_accounts_on_server_id"
  end

  create_table "server_stats", force: :cascade do |t|
    t.string "period", null: false
    t.date "reference_date", null: false
    t.bigint "game_id", null: false
    t.string "country_code", null: false
    t.bigint "server_id", null: false
    t.bigint "vote_count", default: 0, null: false
    t.datetime "vote_count_consolidated_at"
    t.bigint "ranking_number"
    t.datetime "ranking_number_consolidated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period", "reference_date", "game_id", "country_code", "server_id"], name: "index_server_stats_on_period_reference_app_country_server", unique: true
    t.index ["server_id"], name: "index_server_stats_on_server_id"
  end

  create_table "server_votes", force: :cascade do |t|
    t.string "reference", default: "", null: false
    t.string "remote_ip", default: "", null: false
    t.bigint "account_id"
    t.bigint "game_id", null: false
    t.string "country_code", null: false
    t.bigint "server_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_server_votes_on_account_id"
    t.index ["created_at"], name: "index_server_votes_on_created_at"
    t.index ["game_id", "country_code"], name: "index_server_votes_on_game_id_and_country_code"
    t.index ["server_id"], name: "index_server_votes_on_server_id"
    t.index ["uuid"], name: "index_server_votes_on_uuid", unique: true
  end

  create_table "servers", force: :cascade do |t|
    t.string "name", null: false
    t.string "country_code", null: false
    t.string "site_url", null: false
    t.string "description", default: "", null: false
    t.text "info", default: "", null: false
    t.bigint "game_id", null: false
    t.datetime "verified_at"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "archived_at"
    t.datetime "marked_for_deletion_at"
    t.datetime "banner_image_approved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_servers_on_archived_at"
    t.index ["country_code"], name: "index_servers_on_country_code"
    t.index ["game_id"], name: "index_servers_on_game_id"
    t.index ["marked_for_deletion_at"], name: "index_servers_on_marked_for_deletion_at"
    t.index ["name"], name: "index_servers_on_name"
    t.index ["verified_at"], name: "index_servers_on_verified_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "token_digest", null: false
    t.string "token_last_four", null: false
    t.string "remote_ip", null: false
    t.string "user_agent", default: "", null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_sessions_on_token_digest", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "token_digest", null: false
    t.string "token_last_four", null: false
    t.string "purpose", null: false
    t.datetime "expires_at", null: false
    t.jsonb "data", default: {}, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_tokens_on_expires_at"
    t.index ["purpose"], name: "index_tokens_on_purpose"
    t.index ["token_digest"], name: "index_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_tokens_on_user_id"
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

  create_table "webhook_configs", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.string "event_types", default: ["*"], null: false, array: true
    t.string "method", default: "POST", null: false
    t.string "url", null: false
    t.string "secret", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_webhook_configs_on_source_type_and_source_id"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "webhook_config_id", null: false
    t.string "type", null: false
    t.string "status", null: false
    t.jsonb "data", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_published_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_webhook_events_on_type"
    t.index ["uuid"], name: "index_webhook_events_on_uuid", unique: true
    t.index ["webhook_config_id"], name: "index_webhook_events_on_webhook_config_id"
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_account_roles", "admin_accounts"
  add_foreign_key "admin_account_roles", "admin_roles"
  add_foreign_key "admin_accounts", "admin_users"
  add_foreign_key "admin_codes", "admin_users"
  add_foreign_key "admin_role_permissions", "admin_permissions"
  add_foreign_key "admin_role_permissions", "admin_roles"
  add_foreign_key "admin_sessions", "admin_users"
  add_foreign_key "admin_tokens", "admin_users"
  add_foreign_key "codes", "users"
  add_foreign_key "server_accounts", "accounts"
  add_foreign_key "server_accounts", "servers"
  add_foreign_key "server_stats", "games"
  add_foreign_key "server_stats", "servers"
  add_foreign_key "server_votes", "accounts"
  add_foreign_key "server_votes", "games"
  add_foreign_key "server_votes", "servers"
  add_foreign_key "servers", "games"
  add_foreign_key "sessions", "users"
  add_foreign_key "tokens", "users"
  add_foreign_key "webhook_events", "webhook_configs"
end
