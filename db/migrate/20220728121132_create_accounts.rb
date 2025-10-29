# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: false

      t.uuid :uuid, null: false, default: "uuidv7()"

      t.timestamps
    end

    add_index :accounts, :uuid,    unique: true
    add_index :accounts, :user_id, unique: true
  end
end
