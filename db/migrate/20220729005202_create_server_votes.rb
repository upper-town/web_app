# frozen_string_literal: true

class CreateServerVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :server_votes do |t|
      t.string :reference, null: true
      t.string :remote_ip, null: false

      t.references :account, null: true, foreign_key: true, index: false

      t.references :game,         null: false, foreign_key: true, index: false
      t.string     :country_code, null: false
      t.references :server,       null: false, foreign_key: true, index: false

      t.uuid :uuid, null: false, default: "uuidv7()"

      t.timestamps
    end

    add_index :server_votes, :account_id
    add_index :server_votes, [:game_id, :country_code]
    add_index :server_votes, :server_id
    add_index :server_votes, :created_at
    add_index :server_votes, :uuid, unique: true
  end
end
