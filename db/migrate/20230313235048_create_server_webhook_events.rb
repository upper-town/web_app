# frozen_string_literal: true

class CreateServerWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :server_webhook_events do |t|
      t.references :server, null: false, foreign_key: true, index: false

      t.uuid     :uuid,              null: false
      t.string   :type,              null: false
      t.jsonb    :payload,           null: false, default: {}
      t.string   :status,            null: false
      t.string   :notice,            null: false, default: ''
      t.integer  :failed_attempts,   null: false, default: 0
      t.datetime :last_published_at, null: true
      t.datetime :delivered_at,      null: true

      t.references :server_webhook_config, null: true, foreign_key: true, index: false

      t.timestamps
    end

    add_index :server_webhook_events, :uuid, unique: true
    add_index :server_webhook_events, :type
    add_index :server_webhook_events, :server_id
    add_index :server_webhook_events, :server_webhook_config_id
  end
end
