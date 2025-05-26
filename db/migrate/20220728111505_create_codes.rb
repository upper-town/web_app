# frozen_string_literal: true

class CreateCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :codes do |t|
      t.string   :code_digest,    null: false
      t.string   :purpose,        null: false
      t.datetime :expires_at,     null: false
      t.jsonb    :data,           null: false, default: {}

      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :codes, :purpose
    add_index :codes, :expires_at
    add_index :codes, :user_id
    add_index :codes, :code_digest, unique: true
  end
end
