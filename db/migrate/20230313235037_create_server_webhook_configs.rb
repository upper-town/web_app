class CreateServerWebhookConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :server_webhook_configs do |t|
      t.references :server, null: false, foreign_key: true, index: false

      t.uuid     :uuid,            null: false
      t.string   :event_type,      null: false
      t.string   :url,             null: false, default: ''
      t.string   :notice,          null: false
      t.datetime :disabled_at,     null: true

      t.timestamps
    end

    add_index :server_webhook_configs, :uuid,                     unique: true
    add_index :server_webhook_configs, [:server_id, :event_type], unique: true
  end
end
