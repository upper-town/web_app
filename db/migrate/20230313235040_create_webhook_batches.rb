# frozen_string_literal: true

class CreateWebhookBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_batches do |t|
      t.references :webhook_config, null: false, foreign_key: true, index: false

      t.string  :status,          null: false
      t.integer :failed_attempts, null: false, default: 0
      t.jsonb   :metadata,        null: false, default: {}

      t.timestamps
    end

    add_index :webhook_batches, :webhook_config_id
    add_index :webhook_batches, :status
  end
end
