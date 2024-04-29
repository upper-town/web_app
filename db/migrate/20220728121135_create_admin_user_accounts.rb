# frozen_string_literal: true

class CreateAdminUserAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_user_accounts do |t|
      t.references :admin_user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_user_accounts, :admin_user_id, unique: true
  end
end
