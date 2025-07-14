# frozen_string_literal: true

class CreateServers < ActiveRecord::Migration[7.1]
  def change
    create_table :servers do |t|
      t.string :name,             null: false
      t.string :country_code,     null: false
      t.string :site_url,         null: false
      t.string :description,      null: false, default: ""
      t.text   :info,             null: false, default: ""

      t.references :game, null: false, foreign_key: true, index: false

      t.datetime :verified_at,            null: true
      t.jsonb    :metadata,               null: false, default: {}
      t.datetime :archived_at,            null: true
      t.datetime :marked_for_deletion_at, null: true

      t.timestamps
    end

    add_index :servers, :name
    add_index :servers, :game_id
    add_index :servers, :country_code
    add_index :servers, :verified_at
    add_index :servers, :archived_at
    add_index :servers, :marked_for_deletion_at
  end
end
