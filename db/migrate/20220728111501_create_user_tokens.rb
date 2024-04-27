# frozen_string_literal: true

class CreateUserTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :user_tokens do |t|
      t.string   :value,      null: false
      t.string   :purpose,    null: false
      t.datetime :expires_at, null: false
      t.jsonb    :data,       null: false, default: {}

      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :user_tokens, :value, unique: true
    add_index :user_tokens, :purpose
    add_index :user_tokens, :expires_at
    add_index :user_tokens, :user_id
  end
end
