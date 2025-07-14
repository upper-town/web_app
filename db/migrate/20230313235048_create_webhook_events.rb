# frozen_string_literal: true

class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"

      t.references :webhook_config, null: false, foreign_key: true, index: false

      t.string   :type,              null: false
      t.string   :status,            null: false
      t.jsonb    :data,              null: false, default: {}
      t.jsonb    :metadata,          null: false, default: {}
      t.integer  :failed_attempts,   null: false, default: 0
      t.datetime :last_published_at, null: true
      t.datetime :delivered_at,      null: true

      t.timestamps
    end

    add_index :webhook_events, :uuid, unique: true
    add_index :webhook_events, :webhook_config_id
    add_index :webhook_events, :type
  end
end
