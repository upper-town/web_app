class CreateServerAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :server_accounts do |t|
      t.references :server,       null: false, foreign_key: true, index: false
      t.references :account, null: false, foreign_key: true, index: false

      t.datetime :verified_at, null: true

      t.timestamps
    end

    add_index(:server_accounts, :server_id)
    add_index(:server_accounts, [ :account_id, :server_id ], unique: true)
  end
end
