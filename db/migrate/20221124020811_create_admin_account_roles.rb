# frozen_string_literal: true

class CreateAdminAccountRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_account_roles do |t|
      t.references :admin_account, null: false, foreign_key: true, index: false
      t.references :admin_role,    null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index(
      :admin_account_roles,
      [:admin_account_id, :admin_role_id],
      unique: true,
      name: 'index_admin_account_roles_account_id_role_id'
    )
    add_index :admin_account_roles, :admin_role_id
  end
end
