# frozen_string_literal: true

class CreateServerWebhookConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :server_webhook_configs do |t|
      t.references :server, null: false, foreign_key: true, index: false

      t.string   :method,       null: false, default: "POST"
      t.string   :url,          null: false
      t.string   :event_types,  null: false, array: true, default: ["*"]
      t.string   :secret,       null: false
      t.string   :notice,       null: false, default: ""
      t.datetime :disabled_at,  null: true

      t.timestamps
    end

    add_index :server_webhook_configs, :server_id
  end
end
