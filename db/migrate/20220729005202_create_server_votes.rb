# frozen_string_literal: true

class CreateServerVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :server_votes do |t|
      t.references :server, null: false, foreign_key: true

      t.uuid  :uuid,     null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
