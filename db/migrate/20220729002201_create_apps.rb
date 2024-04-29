# frozen_string_literal: true

class CreateApps < ActiveRecord::Migration[7.1]
  def change
    create_table :apps do |t|
      t.string :slug,        null: false
      t.string :name,        null: false
      t.string :type,        null: false
      t.string :site_url,    null: false, default: ''
      t.string :description, null: false, default: ''
      t.text   :info,        null: false, default: ''

      t.timestamps
    end

    add_index :apps, :slug, unique: true
    add_index :apps, :name, unique: true

    add_index :apps, :type
  end
end
