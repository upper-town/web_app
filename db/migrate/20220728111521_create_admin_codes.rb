# frozen_string_literal: true

class CreateAdminCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_codes do |t|
      t.string   :code_digest,    null: false
      t.string   :purpose,        null: false
      t.datetime :expires_at,     null: false
      t.jsonb    :data,           null: false, default: {}

      t.references :admin_user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_codes, :purpose
    add_index :admin_codes, :expires_at
    add_index :admin_codes, :admin_user_id
    add_index :admin_codes, :code_digest, unique: true
  end
end
