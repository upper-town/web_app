# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.string   :token_digest,    null: false
      t.string   :token_last_four, null: false
      t.string   :remote_ip,       null: false
      t.string   :user_agent,      null: false, default: ""
      t.datetime :expires_at,      null: false

      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :sessions, :user_id
    add_index :sessions, :token_digest, unique: true
  end
end
