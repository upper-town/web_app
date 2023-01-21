# frozen_string_literal: true

class CreateServerVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :server_votes do |t|
      t.uuid  :uuid,     null: false
      t.jsonb :metadata, null: false, default: {}

      t.references :user_account, null: false, foreign_key: true, index: false

      t.references :server,       null: false, foreign_key: true, index: false
      t.references :app,          null: false, foreign_key: true, index: false
      t.string     :country_code, null: false

      t.timestamps
    end

    add_index :server_votes, :uuid, unique: true

    add_index :server_votes, :user_account_id
    add_index :server_votes, :server_id
    add_index :server_votes, :app_id
    add_index :server_votes, :country_code
  end
end
