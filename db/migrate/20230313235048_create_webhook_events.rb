# frozen_string_literal: true

class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events do |t|
      t.references :webhook_config, null: false, foreign_key: true, index: false
      t.references :webhook_batch,  null: true,  foreign_key: true, index: false

      t.uuid   :uuid,     null: false
      t.string :type,     null: false
      t.jsonb  :data,     null: false, default: {}
      t.jsonb  :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :webhook_events, [:webhook_config_id, :uuid], unique: true
    add_index :webhook_events, :webhook_batch_id
    add_index :webhook_events, :uuid
    add_index :webhook_events, :type
  end
end
