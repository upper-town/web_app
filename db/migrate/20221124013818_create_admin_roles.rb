# frozen_string_literal: true

class CreateAdminRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_roles do |t|
      t.string :key,         null: false, default: '', index: { unique: true }
      t.string :description, null: false, default: ''

      t.timestamps
    end
  end
end
