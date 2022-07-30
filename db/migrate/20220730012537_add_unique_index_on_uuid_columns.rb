class AddUniqueIndexOnUuidColumns < ActiveRecord::Migration[7.1]
  def change
    add_index :servers,      :uuid, unique: true
    add_index :server_votes, :uuid, unique: true
    add_index :users,        :uuid, unique: true
    add_index :admin_users,  :uuid, unique: true
  end
end
