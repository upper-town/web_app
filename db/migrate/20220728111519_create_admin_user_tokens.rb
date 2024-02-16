# frozen_string_literal: true

class CreateAdminUserTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_user_tokens do |t|
      t.string   :value,      null: false
      t.string   :purpose,    null: false
      t.datetime :expires_at, null: false

      t.references :admin_user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_user_tokens, :value, unique: true
    add_index :admin_user_tokens, :purpose
    add_index :admin_user_tokens, :expires_at
    add_index :admin_user_tokens, :admin_user_id
  end
end
