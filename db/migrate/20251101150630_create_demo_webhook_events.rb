class CreateDemoWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_webhook_events do |t|
      t.uuid    :uuid,     null: false
      t.string  :type,     null: false
      t.jsonb   :data,     null: false, default: {}
      t.jsonb   :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :demo_webhook_events, :uuid, unique: true
    add_index :demo_webhook_events, :type
  end
end
