# frozen_string_literal: true

class CreateServers < ActiveRecord::Migration[7.1]
  def change
    create_table :servers do |t|
      t.uuid   :uuid,             null: false
      t.string :name,             null: false
      t.string :country_code,     null: false
      t.string :site_url,         null: false
      t.string :banner_image_url, null: false, default: ''
      t.string :description,      null: false, default: ''
      t.text   :info,             null: false, default: ''

      t.string   :verified_status,     null: false, default: 'pending'
      t.text     :verified_notice,     null: false, default: ''
      t.datetime :verified_updated_at, null: true

      t.references :app, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :servers, :uuid,            unique: true
    add_index :servers, [:name, :app_id], unique: true

    add_index :servers, :app_id
    add_index :servers, :country_code
  end
end
