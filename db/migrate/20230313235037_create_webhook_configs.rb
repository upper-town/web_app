# frozen_string_literal: true

class CreateWebhookConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_configs do |t|
      t.references :source, polymorphic: true, null: false, index: false

      t.string   :event_types, null: false, array: true, default: ["*"]
      t.string   :method,      null: false, default: "POST"
      t.string   :url,         null: false
      t.string   :secret,      null: false
      t.jsonb    :metadata,    null: false, default: {}
      t.datetime :disabled_at, null: true

      t.timestamps
    end

    add_index :webhook_configs, [:source_type, :source_id]
  end
end
