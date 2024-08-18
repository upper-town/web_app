# frozen_string_literal: true

class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.string   :token,      null: false
      t.string   :purpose,    null: false
      t.datetime :expires_at, null: false
      t.jsonb    :data,       null: false, default: {}

      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :tokens, :token, unique: true
    add_index :tokens, :purpose
    add_index :tokens, :expires_at
    add_index :tokens, :user_id
  end
end
