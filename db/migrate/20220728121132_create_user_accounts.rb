# frozen_string_literal: true

class CreateUserAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :user_accounts do |t|
      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :user_accounts, :user_id, unique: true
  end
end
