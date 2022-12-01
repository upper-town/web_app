# frozen_string_literal: true

class CreateAdminPermissions < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_permissions do |t|
      t.string :key,         null: false, default: '', index: { unique: true }
      t.string :description, null: false, default: ''

      t.timestamps
    end
  end
end
