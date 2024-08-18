# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :accounts, :user_id, unique: true
  end
end
