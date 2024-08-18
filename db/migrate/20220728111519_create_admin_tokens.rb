# frozen_string_literal: true

class CreateAdminTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_tokens do |t|
      t.string   :token,      null: false
      t.string   :purpose,    null: false
      t.datetime :expires_at, null: false
      t.jsonb    :data,       null: false, default: {}

      t.references :admin_user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_tokens, :token, unique: true
    add_index :admin_tokens, :purpose
    add_index :admin_tokens, :expires_at
    add_index :admin_tokens, :admin_user_id
  end
end
