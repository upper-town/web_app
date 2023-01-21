# frozen_string_literal: true

class CreateAdminUserRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_user_roles do |t|
      t.references :admin_user, null: false, foreign_key: true, index: false
      t.references :admin_role, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :admin_user_roles, [:admin_user_id, :admin_role_id], unique: true
    add_index :admin_user_roles, :admin_role_id
  end
end
