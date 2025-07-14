# frozen_string_literal: true

class CreateAdminUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_users do |t|
      t.string   :email, null: false
      t.datetime :email_confirmed_at
      t.datetime :email_confirmation_sent_at

      t.string   :password_digest
      t.datetime :password_reset_at
      t.datetime :password_reset_sent_at

      t.integer :sign_in_count,   null: false, default: 0
      t.integer :failed_attempts, null: false, default: 0

      t.datetime :locked_at
      t.string   :locked_reason
      t.text     :locked_comment

      t.timestamps
    end

    add_index :admin_users, :email, unique: true
  end
end
