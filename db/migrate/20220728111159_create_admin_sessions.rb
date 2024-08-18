# frozen_string_literal: true

class CreateAdminSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_sessions do |t|
      t.string   :token,      null: false
      t.string   :remote_ip,  null: false
      t.string   :user_agent, null: false, default: ''
      t.datetime :expires_at, null: false

      t.references :admin_user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_sessions, :token, unique: true

    add_index :admin_sessions, :admin_user_id
  end
end
