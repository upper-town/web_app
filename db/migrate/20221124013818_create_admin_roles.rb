class CreateAdminRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_roles do |t|
      t.string :key,         null: false
      t.string :description, null: false, default: ''

      t.timestamps
    end

    add_index :admin_roles, :key, unique: true
  end
end
