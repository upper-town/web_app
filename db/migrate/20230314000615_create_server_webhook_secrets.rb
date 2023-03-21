class CreateServerWebhookSecrets < ActiveRecord::Migration[7.1]
  def change
    create_table :server_webhook_secrets do |t|
      t.references :server, null: false, foreign_key: true, index: false

      t.uuid     :uuid,        null: false
      t.string   :value,       null: false
      t.datetime :archived_at, null: true

      t.timestamps
    end

    add_index :server_webhook_secrets, :uuid, unique: true
    add_index :server_webhook_secrets, :server_id
  end
end
