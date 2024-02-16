# frozen_string_literal: true

class CreateAdminUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_users do |t|
      t.uuid :uuid, null: false

      t.string :email, null: false
      t.string :password_digest

      t.datetime :password_reset_at
      t.datetime :password_reset_sent_at

      t.integer :sign_in_count,   null: false, default: 0
      t.integer :failed_attempts, null: false, default: 0

      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      t.datetime :locked_at
      t.string   :locked_reason
      t.text     :locked_comment

      t.timestamps
    end

    add_index :admin_users, :uuid,  unique: true
    add_index :admin_users, :email, unique: true
  end
end
